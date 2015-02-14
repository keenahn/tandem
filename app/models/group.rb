# A grouping of members and pairs
class Group < ActiveRecord::Base

  belongs_to :user, touch: true
  has_and_belongs_to_many :members
  has_many :pairs

  scope :ordered, -> { order(:name) }

  def to_s
    name
  end

end
