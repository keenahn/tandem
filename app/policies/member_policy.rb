# Policy for manipulating members
class MemberPolicy < ApplicationPolicy

  # Scope for groups
  class Scope < Scope

    def resolve
      return nil unless user
      group_ids = user.groups.pluck(:id)
      member_ids = GroupMembership.where(group_id: group_ids).pluck(:member_id)
      return scope.where(id: member_ids)
    end

  end

  def edit?
    owns?
  end

  def show?
    owns?
  end

  def update?
    owns?
  end

  def destroy?
    owns?
  end

  private

  def owns?
    record.owner_id == user.id
  end

end
