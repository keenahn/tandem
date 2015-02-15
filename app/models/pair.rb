# A pairing of two members
class Pair < ActiveRecord::Base

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"

  # Returns AR object of members
  def members
    Member.where(id: [member_1_id, member_2_id])
  end

end
