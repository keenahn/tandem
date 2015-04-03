# A grouping of members and pairs
class Group < ActiveRecord::Base

  ##############################################################################
  # INCLUDES
  ##############################################################################

  include Concerns::ActiveRecordExtensions

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

  belongs_to :owner, touch: true, class_name: "User"
  has_many :members, through: :group_memberships, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :pairs, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :activity, inclusion: { in: Tandem::Activity::ACTIVITIES }

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_validation(on: :create) do
    set_defaults
  end

  ##############################################################################
  # SCOPES
  ##############################################################################

  scope :ordered, -> { order(:name) }

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  def to_s
    name
  end

  def add_member m
    GroupMembership.find_or_create_by(group_id: id, member_id: m.id)
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.time_zone ||= owner.time_zone
    self.activity  ||= Tandem::Activity::DEFAULT_ACTIVITY
  end

end
