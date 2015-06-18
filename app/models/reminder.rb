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
  DEFAULT_WINDOW  = 15

  # How much after the initial reminder to send the no_reply message
  NO_REPLY_MINUTES = 10

  # How often we'll be sending the no_reply messages
  NO_REPLY_WINDOW = 5


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

  def self.send_reminders window = DEFAULT_WINDOW
    time_range = (Time.now - window.minutes)..Time.now
    Reminder.unsent.where(next_reminder_time_utc: time_range).each{ |x|
      next if x.checkin_done? # don't send reminders if the user checked in EARLY
      x.send_reminder
    }
  end

  # TODO: unit tests
  def self.send_no_reply_messages window = NO_REPLY_WINDOW, no_reply_minutes = NO_REPLY_MINUTES

    oldest_reminder_sent_time = Time.now - no_reply_minutes.minutes

    time_range = (oldest_reminder_sent_time - window.minutes)..oldest_reminder_sent_time

    # send no reply messages IF
    #   1. If the checkin is still not marked as done AND
    #   2. it is no_reply_minutes minutes AFTER the last sent reminder

    # Naiive way: loop through all pairs linked to sent reminders
    pair_ids = Reminder.sent.where(last_reminder_time_utc: time_range).pluck(:pair_id).uniq

    Pair.where(id: pair_ids).includes(:member_1, :member_2).each do |pair|
      member_1 = pair.member_1
      member_2 = pair.member_2

      # TODO: refactor this
      c1 = Checkin.find_by(member_id: member_1.id, pair_id: pair.id, local_date: pair.local_date)
      c2 = Checkin.find_by(member_id: member_2.id, pair_id: pair.id, local_date: pair.local_date)

      next if c1 && c1.done? && c2 && c2.done?
      if c1.try(:done?)
        if !c2.try(:done?)
          # send doer no reply messages to member_2
          # send helper no reply messages to member_1
          send_doer_helper_no_reply_messages(member_2, member_1)
        end
      else # !c1.done?
        if c2.try(:done?)
          # send doer no reply messages to member_1
          # send helper no reply messages to member_2
          send_doer_helper_no_reply_messages(member_1, member_2)
        else
          # send both no reply messages to member_1 and member_2
          send_both_no_reply_messages(member_1, member_2)
        end
      end

    end
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # TODO: unit tests
  def send_reminder
    # determine which text message(s) to send
    member_message = Member::Message.new(member)
    message_strings = member_message.current_reminder_messages(activity_args)

    # Send the messages using SMS
    send_sms(message_strings)

    member.increment_reminder_count!
    mark_sent!
  end

  # TODO: unit tests
  # TODO: move elsewhere....
  # TODO
  def send_doer_helper_no_reply_messages doer, helper
    # determine which text message(s) to send
    doer_message   = Member::Message.new(doer)
    helper_message = Member::Message.new(helper)

    doer_message_strings   = doer_message.current_doer_no_reply_messages
    helper_message_strings = helper_message.current_helper_no_reply_messages

    # Send the messages using SMS
    send_sms(doer_message_strings, doer)
    send_sms(helper_message_strings, helper)

    # member.increment_reminder_count!
    # mark_sent!
  end


  # TODO: unit tests
  def send_sms message_strings, m = nil
    Sms.create_and_send(
      from:    pair,
      to:      m ? m : member,
      message: message_strings
    )
  end

  def activity_args
    activity_tenses = I18n.t("tandem.activities.#{pair.activity}")
    Hash[activity_tenses.map{|k,v| ["activity_#{k}".to_sym, v]}]
  end

  # TODO: unit tests
  def to_s
    "Reminder: #{id} Pair: #{pair_id}, Member: #{member}, Status: #{status},
     Next Reminder Time: #{next_reminder_time_utc} ".squish
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

  def reschedule utc_time
    self.next_reminder_time_utc = utc_time
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

  def checkin_done?
    checkin && checkin.done?
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

end
