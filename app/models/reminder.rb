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

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :member,     presence: true
  validates :pair,       presence: true

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
    # TODO

    # TODO: determine which text message(s) to send
    # Send them

    puts "Sending #{self}"
    self.status = :sent
    save
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



  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

end


