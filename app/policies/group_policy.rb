class GroupPolicy < ApplicationPolicy

  class Scope < Scope

    def resolve
      scope.where(:user_id => user.id)
    end

  end

  def edit?
    record.user_id == user.id
  end

end