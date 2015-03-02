# A grouping of members and pairs
class Group < ActiveRecord::Base

  belongs_to :owner, touch: true, class_name: "User"
  has_many :members, through: :group_memberships, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :pairs, dependent: :destroy


  before_validation(on: :create) do
    set_defaults
  end

  # before_create :set_defaults

  validates :activity, inclusion: { in: Tandem::Activity::ACTIVITIES }

  scope :ordered, -> { order(:name) }

  def to_s
    name
  end

  private

  def set_defaults
    self.time_zone ||= owner.time_zone
    self.activity  ||= Tandem::Activity::DEFAULT_ACTIVITY
  end

end
