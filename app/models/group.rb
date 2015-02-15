# A grouping of members and pairs
class Group < ActiveRecord::Base

  belongs_to :owner, touch: true, class_name: "User"
  has_many :members, through: :group_memberships, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :pairs, dependent: :destroy

  scope :ordered, -> { order(:name) }

  def to_s
    name
  end

end
