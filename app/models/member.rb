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

  NEUTRAL = 0
  MALE    = 1
  FEMALE  = 2

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
            9 => :seen_first_doer_reschedule,
           10 => :seen_second_doer_reschedule,
           11 => :seen_first_helper_reschedule,
           12 => :seen_second_helper_reschedule,
           13 => :seen_first_doer_no_reply,
           14 => :seen_second_doer_no_reply,
           15 => :seen_first_helper_no_reply,
           16 => :seen_second_helper_no_reply,
           17 => :seen_first_both_no_reply,
           18 => :seen_second_both_no_reply,
           column: "message_flags"

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################

  # This automatically adds the predicates male? female? neutral?
  enum gender: {
    male:     MALE,
    female:   FEMALE,
    neutral:  NEUTRAL
  }

  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  has_many :groups, through: :group_memberships
  has_many :group_memberships, dependent: :destroy
  has_many :checkins, dependent: :destroy
  has_many :reminders, dependent: :destroy

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

  scope :owned_by, ->(user_id) {
    gids_sql  = Group.where(owner_id: user_id).select(:id).to_sql
    gmids_sql = GroupMembership.where("group_memberships.group_id IN (#{gids_sql})").select(:member_id).to_sql
    Member.where("#{table_name}.id IN (#{gmids_sql})")
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

  # TODO: DRY all the message count stuff

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

  # TODO: unit tests
  # Doesn't save
  def increment_doer_reschedule_count
    return true if seen_second_doer_reschedule?
    if seen_first_doer_reschedule
      self.seen_second_doer_reschedule = true
    else
      self.seen_first_doer_reschedule  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_doer_reschedule_count!
    increment_doer_reschedule_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_helper_reschedule_count
    return true if seen_second_helper_reschedule?
    if seen_first_helper_reschedule
      self.seen_second_helper_reschedule = true
    else
      self.seen_first_helper_reschedule  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_helper_reschedule_count!
    increment_helper_reschedule_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_both_no_reply_count
    return true if seen_second_both_no_reply?
    if seen_first_both_no_reply
      self.seen_second_both_no_reply = true
    else
      self.seen_first_both_no_reply  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_both_no_reply_count!
    increment_both_no_reply_count
    save
  end


  # TODO: unit tests
  # Doesn't save
  def increment_doer_no_reply_count
    return true if seen_second_doer_no_reply?
    if seen_first_doer_no_reply
      self.seen_second_doer_no_reply = true
    else
      self.seen_first_doer_no_reply  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_doer_no_reply_count!
    increment_doer_no_reply_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_helper_no_reply_count
    return true if seen_second_helper_no_reply?
    if seen_first_helper_no_reply
      self.seen_second_helper_no_reply = true
    else
      self.seen_first_helper_no_reply  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_helper_no_reply_count!
    increment_helper_no_reply_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_doer_reminder_count
    increment_reminder_count
  end

  # TODO: unit tests
  # Does save
  def increment_doer_reminder_count!
    increment_doer_reminder_count
    save
  end

  # TODO: unit tests
  # Doesn't save
  def increment_helper_reminder_count
    return true if seen_second_other_reminder?
    if seen_first_other_reminder?
      self.seen_second_other_reminder = true
    else
      self.seen_first_other_reminder  = true
    end
  end

  # TODO: unit tests
  # Does save
  def increment_helper_reminder_count!
    increment_helper_reminder_count
    save
  end

  # TODO: unit tests
  def create_checkin_and_reminder p
    c = Checkin.find_or_initialize_by(member: self, pair: p, local_date: local_date)
    c.save
    c.create_or_update_reminder
  end


  # TODO: unit tests
  def add_to_group g
    GroupMembership.find_or_create_by(member_id: id, group_id: g.id)
  end

  # TODO: unit tests
  def remove_from_group g
    GroupMembership.where(member_id: id, group_id: g.id).destroy_all
  end

  # TODO: unit tests
  def first_name
    np = People::NameParser.new
    name_obj = np.parse(name)
    name_obj[:first].capitalize || name.capitalize
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
    self.active = true if self.active.nil?
    self.gender ||= :neutral
    true
  end

  # TODO: unit tests
  def destroy_pairs
    pairs.destroy_all
  end

  # TODO: unit tests
  def deactivate_pairs
    return true if active?
    pairs.each{ |x| x.deactivate! }
  end

end
