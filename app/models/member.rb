# A single member of a group. NOT a User (which is who admins the members)
class Member < ActiveRecord::Base

  has_and_belongs_to_many :groups
  has_and_belongs_to_many :pairs

  def to_s
    name
  end

end
