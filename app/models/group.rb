class Group < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :members
  has_many :pairs

  def to_s
    name
  end

end
