# A pairing of two members
class Pair < ActiveRecord::Base

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

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"
  has_many :checkins, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :activity, inclusion: { in: Tandem::Activity::ACTIVITIES }
  validates :member_1, presence: true
  validates :member_2, presence: true
  validates :group, presence: true
  validates :activity, presence: true
  validates :active, presence: true


  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_validation(on: :create) do
    set_defaults
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

  scope :active,   ->{ where(active: true)  }
  scope :inactive, ->{ where(active: false) }

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

  # TODO: unit tests
  def activate
    self.active = true
  end

  # TODO: unit tests
  def deactivate
    self.active = false
  end

  # TODO: unit tests
  def activate!
    activate
    save
  end

  # TODO: unit tests
  def deactivate!
    deactivate
    save
  end

  # TODO: unit tests
  def active?
    active ? true : false
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.activity ||= group.activity
    self.active = true
    self.tandem_number ||= ENV["DEFAULT_FROM_NUMBER"]
  end


end
