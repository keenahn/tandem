class Reminder < ActiveRecord::Base
  ##############################################################################
  # INCLUDES
  ##############################################################################

  ##############################################################################
  # CONSTANTS
  ##############################################################################

  UNSENT      = 0
  SENT        = 1
  RESCHEDULED = 2
  DELETED     = 3

  # Determines how much cushion to provide in the timing of reminders
  # We need a cushion because
  #   a. we might be late with sending the reminders
  #   b. we might not want to trigger the sending job every minute
  #
  DEFAULT_WINDOW  = 3

  # How much after the initial reminder to send the no_reply message
  NO_REPLY_MINUTES = 10

  # How often we'll be sending the no_reply messages
  NO_REPLY_WINDOW = 3 # 5


  ##############################################################################
  # MACROS
  ##############################################################################

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################

  enum status: {
    unsent:       UNSENT      ,
    sent:         SENT        ,
    rescheduled:  RESCHEDULED ,
    deleted:      DELETED     ,
  }

  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  belongs_to :member
  belongs_to :pair
  has_one    :group, through: :pair

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :member, presence: true
  validates :pair,   presence: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  ##############################################################################
  # SCOPES
  ##############################################################################

  # TODO: unit tests
  scope :unsent,      -> { where(status: UNSENT)      }
  scope :sent,        -> { where(status: SENT)        }
  scope :rescheduled, -> { where(status: RESCHEDULED) }
  scope :deleted,     -> { where(status: DELETED)     }

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  # TODO: DRY with no reply function
  def self.send_reminders window = DEFAULT_WINDOW
    pair_ids = pair_ids_for_reminder_messages(window)
    Pair.active.where(id: pair_ids).includes(:member_1, :member_2).each do |pair|

      # TODO: DRY
      member_1 = pair.member_1
      member_2 = pair.member_2
      c1 = Checkin.find_by(member_id: member_1.id, pair_id: pair.id, local_date: member_1.local_date)
      c2 = Checkin.find_by(member_id: member_2.id, pair_id: pair.id, local_date: member_2.local_date)
      r1 = Reminder.find_by(member_id: member_1.id, pair_id: pair.id)
      r2 = Reminder.find_by(member_id: member_2.id, pair_id: pair.id)

      next if c1 && c1.done? && c2 && c2.done?

      # If one user rescheduled, it actually becomes a "one-way" relationship temporarily
      if r1.current? && r2.current?
        if c1.try(:done?)
          if !c2.try(:done?)
            r2.send_helper_reminder
            r2.send_doer_reminder
          end
        else # !c1.done?
          if c2.try(:done?)
            r1.send_doer_reminder
            r1.send_helper_reminder
          else
            r1.send_reminder
            r2.send_reminder
          end
        end
      elsif r1.current?
        next if c1.try(:done?)
        r1.send_doer_reminder
        r1.send_helper_reminder
      elsif r2.current?
        next if c2.try(:done?)
        r2.send_helper_reminder
        r2.send_doer_reminder
      end

    end
  end

  # TODO: unit tests
  def self.pair_ids_for_reminder_messages window = DEFAULT_WINDOW
    time_range = (Time.now - window.minutes)..Time.now
    Reminder.unsent.where(next_reminder_time_utc: time_range).pluck(:pair_id).uniq
  end

  def self.pair_ids_for_no_reply_messages window = NO_REPLY_WINDOW, no_reply_minutes = NO_REPLY_MINUTES
    oldest_reminder_sent_time = Time.now - no_reply_minutes.minutes
    time_range = (oldest_reminder_sent_time - window.minutes)..oldest_reminder_sent_time
    return Reminder.sent.where(last_reminder_time_utc: time_range, last_no_reply_sent_time_utc: nil).pluck(:pair_id).uniq
  end

  # TODO: unit tests
  def self.send_no_reply_messages window = NO_REPLY_WINDOW, no_reply_minutes = NO_REPLY_MINUTES
    pair_ids = pair_ids_for_no_reply_messages(window, no_reply_minutes)
    # Naiive way: loop through all pairs linked to sent reminders
    # send no reply messages IF
    #   1. If the checkin is still not marked as done AND
    #   2. it is no_reply_minutes minutes AFTER the last sent reminder

    Pair.active.where(id: pair_ids).includes(:member_1, :member_2).each do |pair|
      member_1 = pair.member_1
      member_2 = pair.member_2

      # TODO: refactor this
      c1 = Checkin.find_by(member_id: member_1.id, pair_id: pair.id, local_date: member_1.local_date)
      c2 = Checkin.find_by(member_id: member_2.id, pair_id: pair.id, local_date: member_2.local_date)
      r1 = Reminder.find_by(member_id: member_1.id, pair_id: pair.id)
      r2 = Reminder.find_by(member_id: member_2.id, pair_id: pair.id)

      next if c1 && c1.done? && c2 && c2.done?

      # If one user rescheduled, it actually becomes a "one-way" relationship temporarily
      # if r1.current? && r2.current?

      if r1.current? && r2.current?
        if c1.try(:done?)
          if !c2.try(:done?)
            r1.send_helper_no_reply_messages
            r2.send_doer_no_reply_messages
          end
        else # !c1.done?
          if c2.try(:done?)
            r1.send_doer_no_reply_messages
            r2.send_helper_no_reply_messages
          else
            r1.send_both_no_reply_messages
            r2.send_both_no_reply_messages
          end
        end
      elsif r1.current?
        next if c1.try(:done?)
        r1.send_doer_no_reply_messages
        r2.send_helper_no_reply_messages
      elsif r2.current?
        r1.send_helper_no_reply_messages
        r2.send_doer_no_reply_messages
      end
    end
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  def send_reminder
    # determine which text message(s) to send
    member_message  = Member::Message.new(member)

    # if current?
    message_strings = member_message.current_reminder_messages(activity_args)

    # Send 'em
    send_sms(message_strings)
    member.increment_reminder_count!
    mark_sent!
  end

  # TODO: unit tests
  def send_doer_reminder
    doer = member
    doer_message = Member::Message.new(doer)
    doer_message_strings = doer_message.current_doer_reminder_messages(reminder_and_no_reply_args)
    send_sms(doer_message_strings, doer)
    doer.increment_doer_reminder_count!
    mark_sent!
  end

  # TODO: unit tests
  # This one works a bit differently from the others in that it sends
  # a message to the partner only and doesn't mark the reminder as sent
  # That's because it will only be called in tandem (ahem) with send_doer_reminder
  def send_helper_reminder
    helper = other_member
    helper_message = Member::Message.new(helper)
    helper_message_strings = helper_message.current_helper_reminder_messages(reminder_and_no_reply_args(true))
    send_sms(helper_message_strings, helper)
    helper.increment_helper_reminder_count!
    # mark_sent!

  end

  def send_doer_no_reply_messages
    doer = member
    doer_message = Member::Message.new(doer)
    doer_message_strings = doer_message.current_doer_no_reply_messages(reminder_and_no_reply_args)
    send_sms(doer_message_strings, doer)
    doer.increment_doer_no_reply_count!
    mark_no_reply_sent!
  end

  def send_helper_no_reply_messages
    helper = member
    helper_message = Member::Message.new(helper)
    helper_message_strings = helper_message.current_helper_no_reply_messages(reminder_and_no_reply_args(true))
    send_sms(helper_message_strings, helper)
    helper.increment_helper_no_reply_count!
    # mark_no_reply_sent!
  end

  def send_both_no_reply_messages
    member_message = Member::Message.new(member)
    member_message_strings = member_message.current_both_no_reply_messages(reminder_and_no_reply_args)
    send_sms member_message_strings
    member.increment_both_no_reply_count!
    mark_no_reply_sent!
  end

  def send_sms message_strings, m = nil
    Sms.create_and_send(
      from:    pair,
      to:      m ? m : member,
      message: message_strings
    )
  end

  def activity_args
    Tandem::Message.activity_tenses(pair.activity)
  end

  # TODO: unit tests
  def reminder_and_no_reply_args to_helper = false
    if to_helper
      doer = other_member
      helper = member
    else
      doer = member
      helper = other_member
    end
    doer_first_name            = doer.first_name
    helper_first_name          = helper.first_name
    doer_pronouns              = Tandem::Message.gender_pronouns(doer.gender)
    helper_pronouns            = Tandem::Message.gender_pronouns(helper.gender)
    doer_pronoun_object        = doer_pronouns[:pronoun_object]
    doer_pronoun_subject       = doer_pronouns[:pronoun_subject]
    doer_pronoun_possessive    = doer_pronouns[:pronoun_possessive]
    helper_pronoun_object      = helper_pronouns[:pronoun_object]
    helper_pronoun_subject     = helper_pronouns[:pronoun_subject]
    helper_pronoun_possessive  = helper_pronouns[:pronoun_possessive]

    is_are                  = I18n.t("tandem.general.is") # hardcoded for now
    activity_args.merge(
      doer_first_name: doer_first_name,
      doer_pronoun_object: doer_pronoun_object,
      doer_pronoun_possessive: doer_pronoun_possessive,
      doer_pronoun_subject: doer_pronoun_subject,
      helper_first_name: helper_first_name,
      helper_pronoun_object: helper_pronoun_object,
      helper_pronoun_subject: helper_pronoun_subject,
      helper_pronoun_possessive: helper_pronoun_possessive,
      is_are: is_are
    )
  end


  # TODO: unit tests
  def no_reply_sent?
    !last_no_reply_sent_time_utc.nil?
  end

  def mark_sent
    self.status = :sent
    self.last_reminder_time_utc = Time.now.utc
  end

  def mark_sent!
    mark_sent
    save
  end

  def mark_no_reply_sent
    self.last_no_reply_sent_time_utc = Time.now.utc
  end

  def mark_no_reply_sent!
    mark_no_reply_sent
    save
  end

  def reschedule utc_time
    self.next_reminder_time_utc = utc_time
    self.last_reminder_time_utc = nil # So that we don't trigger "no reply" messages
    self.status = :unsent
    save
  end

  def temp_reschedule utc_time
    self.temp_reschedule_time_utc = utc_time
    self.status = :unsent
    save
  end

  def checkin
    Checkin.find_by(pair_id: pair_id, member_id: member_id, local_date: member.local_date)
  end

  # TODO: unit tests
  def other_member
    return checkin.other_member if checkin && checkin.other_member
    nil
  end

  def checkin_done?
    checkin && checkin.done?
  end

  def local_last_reminder_time
    return last_reminder_time_utc.in_time_zone(member.time_zone) if last_reminder_time_utc
    nil
  end

  def local_last_reminder_date
    local_last_reminder_time.to_date
  end

  # TODO: unit tests
  # Returns true if this reminder is happening right now
  def current?
    tnow = Time.now

    # It's a new reminder that is about to be sent
    return true if  # !last_reminder_time_utc &&
      next_reminder_time_utc < tnow &&
      next_reminder_time_utc >= tnow - NO_REPLY_MINUTES.minutes - NO_REPLY_WINDOW.minutes

    return true if last_reminder_time_utc &&
      last_reminder_time_utc < tnow &&
      last_reminder_time_utc >= tnow - NO_REPLY_MINUTES.minutes - NO_REPLY_WINDOW.minutes


    false
  end

  # TODO: unit tests
  def to_s
    "Reminder: #{id} Pair: #{pair_id}, Member: #{member}, Status: #{status},
     Next Reminder Time: #{next_reminder_time_utc} ".squish
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

end
