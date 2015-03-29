# A single member of a group. NOT a User (which is who admins the members)
class Member < ActiveRecord::Base

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

  has_many :groups, through: :group_memberships
  has_many :group_memberships, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  after_destroy :destroy_pairs

  before_validation(on: :create) do
    set_defaults
  end

  ##############################################################################
  # SCOPES
  ##############################################################################

  scope :in_group, ->(group_id) { g = Group.find_by_id group_id ; g.members if g }

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # Returns AR object of pairs the member belongs to
  # Use this instead of a has_many, even though it is the same functionally
  def pairs
    Pair.with_member_id(id)
  end

  def to_s
    name
  end

  def update_time_zone_from_group group
    self.time_zone = group.time_zone if time_zone.nil?
    save
  end

  # TODO: unit tests
  def can_message? other_member
    in_pair_with? other_member
  end

  # TODO: unit tests
  def in_pair_with? other_member
    Pair.active.with_member_ids(id, other_member.id).exists?
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.active = true
  end

  # TODO: unit tests
  def destroy_pairs
    pairs.destroy_all
  end

end
