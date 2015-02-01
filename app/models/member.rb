class Member < ActiveRecord::Base
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :pairs

  def to_s
    name
  end

end
