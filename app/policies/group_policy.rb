# Policy for manipulating groups
class GroupPolicy < ApplicationPolicy

  # Scope for groups
  class Scope < Scope
    def resolve
      return scope.owned_by(user.id) if user
      nil
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
