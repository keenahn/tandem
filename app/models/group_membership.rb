# A single membership relationship between a group and a member
class GroupMembership < ActiveRecord::Base

  belongs_to :group
  belongs_to :member

  after_create :update_member_time_zone

  private

  def update_member_time_zone
    member.update_time_zone_from_group(group)
  end


end
