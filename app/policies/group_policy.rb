class GroupPolicy < ApplicationPolicy

  class Scope < Scope

    def resolve
      return scope.where(owner_id: user.id) if user
      nil
    end

  end

  def edit?
    record.owner_id == user.id
  end

  def show?
    record.owner_id == user.id
  end

  def update?
    record.owner_id == user.id
  end

  def destroy?
    record.owner_id == user.id
  end

end