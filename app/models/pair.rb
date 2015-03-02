# A pairing of two members
class Pair < ActiveRecord::Base

  belongs_to :group
  belongs_to :member_1, class_name: "Member"
  belongs_to :member_2, class_name: "Member"

  validates :activity, inclusion: { in: Tandem::Activity::ACTIVITIES }

  scope :with_member_id, ->(member_id) { where("member_1_id = ? OR member_2_id = ?", member_id, member_id) }

  before_validation(on: :create) do
    set_defaults
  end

  # Returns AR object of members
  def members
    Member.where(id: [member_1_id, member_2_id])
  end

  private

  def set_defaults
    self.activity ||= group.activity
  end


end
