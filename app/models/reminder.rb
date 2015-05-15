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
  DEFAULT_WINDOW = 15


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

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  def self.send_reminders window = DEFAULT_WINDOW
    time_range = (Time.now - window.minutes)..Time.now
    Reminder.unsent.where(next_reminder_time_utc: time_range).each{ |x|
      x.send_reminder
    }
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################


  # TODO: unit tests
  def send_reminder
    # puts "Sending #{self}"

    # determine which text message(s) to send
    message_strings = current_message_strings.split("\n")

    # Send the messages using SMS
    send_sms(message_strings)

    member.increment_reminder_count!
    mark_sent!
  end


  # TODO: unit tests
  # Doesn't save
  def mark_sent
    self.status = :sent
  end

  # TODO: unit tests
  # Doessave
  def mark_sent!
    mark_sent
    save
  end


  def send_sms message_strings
    message_strings.each{|x|
      Sms.create_and_send(
        from:        pair,
        to:          member,
        message:     x
      )
    }
  end

  # TODO: unit tests
  def current_message_strings
    message_template_name = current_message_template_name
    I18n.t("tandem.messages.#{message_template_name}", activity_args)
  end


  # TODO: unit tests
  # TODO: move to member_message class
  def current_message_template_name
    message_time = "post_second_time"
    message_base = "reminder_simultaneous_same_activities"
    if !member.seen_second_reminder?
      message_time = "first_time"
      message_time = "second_time" if member.seen_first_reminder?
    end
    "#{message_base}_#{message_time}"
  end

  # TODO: unit tests
  def activity_args
    activity_tenses = I18n.t("tandem.activities.#{pair.activity}")
    Hash[activity_tenses.map{|k,v| ["activity_#{k}".to_sym, v]}]
  end

  # TODO: unit tests
  def to_s
    "Reminder: #{id} Pair: #{pair_id}, Member: #{member}, Status: #{status},
     Next Reminder Time: #{next_reminder_time_utc} ".squish
  end

  # Doesn't save
  # TODO: unit tests
  def mark_sent
    self.status = :sent
  end

  # Does save
  # TODO: unit tests
  def mark_sent!
    mark_sent
    save
  end

  # TODO: unit tests
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



  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

end


