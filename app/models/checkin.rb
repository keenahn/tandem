class Checkin < ActiveRecord::Base


  ##############################################################################
  # INCLUDES
  ##############################################################################

  ##############################################################################
  # CONSTANTS
  ##############################################################################

  ##############################################################################
  # MACROS
  ##############################################################################

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################

  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  belongs_to :member
  belongs_to :pair
  delegate :group, to: :pair

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :member,     presence: true
  validates :pair,       presence: true
  validates :local_date, presence: true
  validates :local_date, uniqueness: {scope: [:member_id, :pair_id]}

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_validation(on: :create){ set_defaults }

  ##############################################################################
  # SCOPES
  ##############################################################################

  scope :done, -> { where("#{table_name}.done_at IS NOT NULL") }
  scope :undone, -> { where("#{table_name}.done_at IS NULL") }

  ##############################################################################
  # CLASS METHODS
  ##############################################################################


  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # TODO: unit tests
  def mark_done
    self.done_at = Time.now
  end

  # TODO: unit tests
  def mark_done!
    self.done_at = Time.now
    save
  end

  # TODO: unit tests
  def mark_undone
    self.done_at = nil
  end

  # TODO: unit tests
  def mark_undone!
    mark_undone
    save
  end

  # TODO: unit tests
  def done?
    !done_at.nil?
  end

  # TODO: unit tests
  def other_member
    pair.other_member member
  end

  # TODO: unit tests
  def reminder
    Reminder.find_by(pair_id: pair_id, member_id: member_id)
  end

  # TODO: unit tests
  def create_or_update_reminder
    return true if done?
    r = Reminder.find_or_initialize_by(pair_id: pair_id, member_id: member_id)
    r.update_attributes(
      next_reminder_time_utc: pair.next_reminder_time_utc,
      status: :unsent,
    )
    r.save ? r : nil
  end


  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.local_date ||= member.local_date if member
  end

end
