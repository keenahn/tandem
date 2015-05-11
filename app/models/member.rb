# A single member of a group. NOT a User (which is who admins the members)
class Member < ActiveRecord::Base

  ##############################################################################
  # INCLUDES
  ##############################################################################

  include FlagShihTzu

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

  # For Flag Shih Tzu
  # Tracks what kind of messages the member has already seen
  # We use this to know what messgae to send them next
  # Right now, we have three variants for each message for the
  # first, second, and more than second time
  has_flags 1 => :seen_first_reminder,
            2 => :seen_second_reminder,
            3 => :seen_first_other_reminder,
            4 => :seen_second_other_reminder,
            5 => :seen_first_doer_yes,
            6 => :seen_second_doer_yes,
            7 => :seen_first_helper_yes,
            8 => :seen_second_helper_yes,
            9 => :seen_first_reschedule,
           10 => :seen_second_reschedule,
           11 => :seen_first_other_reschedule,
           12 => :seen_second_other_reschedule,
           13 => :seen_first_no,
           14 => :seen_second_no,
           15 => :seen_first_other_no,
           16 => :seen_second_other_no,
           17 => :seen_first_both_no,
           18 => :seen_second_both_no,
           column: "message_flags"

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
    !active?
  end

  # TODO: unit tests
  def active?
    active
  end

  # TODO: unit tests
  def unsubscribe
    self.active = false
  end

  # TODO: unit tests
  def unsubscribe!
    unsubscribe
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_reminder_count
    return true if seen_second_reminder?
    if seen_first_reminder
      self.seen_second_reminder = true
    else
      self.seen_first_reminder  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_reminder_count!
    increment_reminder_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_doer_yes_count
    return true if seen_second_doer_yes?
    if seen_first_doer_yes
      self.seen_second_doer_yes = true
    else
      self.seen_first_doer_yes  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_doer_yes_count!
    increment_doer_yes_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_helper_yes_count
    return true if seen_second_helper_yes?
    if seen_first_helper_yes
      self.seen_second_helper_yes = true
    else
      self.seen_first_helper_yes  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_helper_yes_count!
    increment_helper_yes_count
    save
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
