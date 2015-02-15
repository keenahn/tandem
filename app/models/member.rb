# A single member of a group. NOT a User (which is who admins the members)
class Member < ActiveRecord::Base

  has_many :groups, through: :group_memberships
  has_many :group_memberships, dependent: :destroy

  after_destroy :destroy_pairs


  # Returns AR object of pairs the member belongs to
  def pairs
    Pair.with_member_id(id)
  end

  def to_s
    name
  end

  private

  # TODO: unit tests
  def destroy_pairs
    pairs.destroy_all
  end

end
