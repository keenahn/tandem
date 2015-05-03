# A single member of a group. NOT a User (which is who admins the members)
class Member < ActiveRecord::Base

  ##############################################################################
  # INCLUDES
  ##############################################################################

  include Concerns::ActiveRecordExtensions
  include Concerns::SmsableMixin
  include Concerns::ActiveInactiveMixin
  include Concerns::LocalTimeMixin

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
  has_many :checkins, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  # TODO: validate first and last name
  # TODO: validate phone number presence and format
  # TODO: validate presence of timezone

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  after_destroy :destroy_pairs
  after_save :deactivate_pairs

  before_validation :clean_phone

  before_validation(on: :create) do
    set_defaults
  end

  ##############################################################################
  # SCOPES
  ##############################################################################

  scope :in_group, ->(group_id) {
    g = Group.find_by_id group_id
    return g.members if g
    none
  }

  # TODO: move to class method?
  scope :has_active_pair, ->{
    subq_1 = Pair.active.select(:member_1_id).to_sql
    subq_2 = Pair.active.select(:member_2_id).to_sql
    where("id IN ((#{subq_1}) UNION (#{subq_2}))")
  }

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

  def can_message? other_member
    in_pair_with? other_member
  end

  def in_pair_with? other_member
    Pair.active.with_member_ids(id, other_member.id).exists?
  end

  # TODO: unit tests
  def unsubscribed?
    #TODO
    false
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def clean_phone
    self.phone_number = Phoner::Phone.parse(phone_number).to_s if phone_number
    true
  end

  def set_defaults
    self.active = true
    true
  end

  # TODO: unit tests
  def destroy_pairs
    pairs.destroy_all
  end

  # TODO: unit tests
  def deactivate_pairs
    pairs.each{ |x| x.deactivate! }
  end

end
