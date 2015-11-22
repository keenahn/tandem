# A pairing of two members
class Pair < ActiveRecord::Base

  ##############################################################################
  # INCLUDES
  ##############################################################################

  include Concerns::ActiveRecordExtensions
  include Concerns::ActiveInactiveMixin
  include Concerns::LocalTimeMixin
  include Concerns::SmsableMixin

  ##############################################################################
  # CONSTANTS
  ##############################################################################

  # All reminder times are LOCAL, based on the time_zone field
  # They are stored in the database as pure time fields
  # which Rails Interprets as UTC. This might be confusing, but it is better
  # than the alternative

  WEEKEND_REMINDER_TIME_FIELDS = [
    :reminder_time_sat,
    :reminder_time_sun,
  ]

  WEEKDAY_REMINDER_TIME_FIELDS = [
    :reminder_time_mon,
    :reminder_time_tue,
    :reminder_time_wed,
    :reminder_time_thu,
    :reminder_time_fri,
  ]

  ALL_REMINDER_TIME_FIELDS = WEEKDAY_REMINDER_TIME_FIELDS + WEEKEND_REMINDER_TIME_FIELDS

  ##############################################################################
  # MACROS
  ##############################################################################

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################



  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"
  has_many :checkins, dependent: :destroy
  has_many :reminders
  delegate :owner, to: :group

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :activity, inclusion: { in: Tandem::Activity::ACTIVITIES }
  validates :member_1, presence: true
  validates :member_2, presence: true
  validates :group, presence: true
  validates :activity, presence: true
  validate :members_different


  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_validation(on: :create) do
    set_defaults
  end

  after_save do
    update_checkins_reminders
    update_group_memberships
  end

  after_save do
    send_welcome_messages if active? && changes[:active]
  end

  ##############################################################################
  # SCOPES
  ##############################################################################

  scope :with_member_id, ->(m_id) {
    where("#{table_name}.member_1_id = ? OR
           #{table_name}.member_2_id = ?",
      m_id, m_id)
  }

  scope :with_member_ids, ->(m1_id, m2_id) {
    where("(#{table_name}.member_1_id = ? AND #{table_name}.member_2_id = ?) OR
           (#{table_name}.member_1_id = ? AND #{table_name}.member_2_id = ?)",
      m1_id, m2_id, m2_id, m1_id)
  }

  scope :in_group, ->(group_id) {
    g = Group.find_by_id group_id
    return g.pairs if g
    none
  }

  scope :owned_by, ->(user_id) {
    gids_sql = Group.where(owner_id: user_id).select(:id).to_sql
    Pair.where("#{table_name}.group_id IN (#{gids_sql})")
  }


  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  # TODO: unit test
  def self.find_by_member_id_and_tandem_number m_id, t_number
    Pair.active.with_member_id(m_id).where(tandem_number: t_number).first
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # Returns AR object of members
  def members
    Member.where(id: [member_1_id, member_2_id])
  end

  # TODO: unit tests
  def other_member mem
    return nil unless (member_1.id == mem.id || member_2.id == mem.id)
    return member_2 if member_1.id == mem.id
    member_1
  end

  # TODO:
  def can_message? m
    return true if m.id == member_1_id || m.id == member_2_id
    false
  end

  # TODO: unit tests
  def set_all_reminder_times t
    ALL_REMINDER_TIME_FIELDS.each{ |f| self[f] = t }
  end

  # TODO: unit tests
  def set_weekday_reminder_time t
    WEEKDAY_REMINDER_TIME_FIELDS.each{ |f| self[f] = t }
  end

  # TODO: unit tests
  def set_weekend_reminder_time t
    WEEKEND_REMINDER_TIME_FIELDS.each{ |f| self[f] = t }
  end

  # TODO: unit tests
  def reminder_time
    reminder_time_mon
  end

  def reminder_time_today
    sym = "reminder_time_#{local_day_of_week_abbrev}".to_sym
    Tandem::Utils.short_time_24(self[sym])
  end

  # Alias
  def reminder_time_today_utc
    next_reminder_time_utc
  end

  def next_reminder_time_utc
    Tandem::Utils.parse_time_in_zone("#{local_date} #{reminder_time_today}", time_zone).utc
  end

  # Alias for sms
  def phone_number
    tandem_number
  end

  def create_checkin_and_reminders
    members.each{|m| m.create_checkin_and_reminder(self) }
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  # TODO: unit tests
  def set_defaults
    self.tandem_number   ||= Phoner::Phone.parse(TwilioClient::DEFAULT_FROM_NUMBER + "").to_s
    if group
      self.activity      ||= group.activity
      self.time_zone     ||= group.time_zone
    end
  end

  # TODO: unit tests
  def members_different
    errors.add(:base, I18n.t("tandem.errors.members_not_different")) if member_1_id == member_2_id
  end

  # TODO: unit tests
  def update_checkins_reminders
    if active?
      create_checkin_and_reminders
    else
      reminders.destroy_all
    end
  end

  # TODO: unit tests
  def update_group_memberships
    member_1.add_to_group group
    member_2.add_to_group group
  end

  def send_welcome_messages
    template = "onboarding_simultaneous_same_activities"
    members.each{ |m|
      messages = Tandem::Message.message_strings(template, welcome_message_args(m))
      Sms.create_and_send(from: self, to: m, message: messages)
    }
  end

  def welcome_message_args mem
    partner = other_member(mem)

    rtime = Tandem::Utils.short_time_24(reminder_time)

    t = Tandem::Utils.parse_time_in_zone(
          "#{local_date} #{rtime}",
          time_zone
        ).in_time_zone(mem.time_zone)

    Tandem::Message.activity_tenses(activity).merge(
      product_name: I18n.t("tandem.general.product_name"),
      member_first_name: mem.first_name,
      partner_first_name: partner.first_name,
      display_time: Tandem::Utils.short_time(t)
    )
  end


end
