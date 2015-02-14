# A pairing of two members
class Pair < ActiveRecord::Base

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"

end
