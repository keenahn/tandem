# A single membership relationship between a group and a member
class GroupMembership < ActiveRecord::Base

  belongs_to :group
  belongs_to :member

end
