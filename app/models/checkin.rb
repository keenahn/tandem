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

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.local_date ||= member.local_date if member
  end

end
