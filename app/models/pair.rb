# A pairing of two members
class Pair < ActiveRecord::Base

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"

  scope :with_member_id, ->(member_id) { where("member_1_id = ? OR member_2_id = ?", member_id, member_id) }

  # Returns AR object of members
  def members
    Member.where(id: [member_1_id, member_2_id])
  end

end
