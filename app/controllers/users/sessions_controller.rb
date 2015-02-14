# Sessions controller from Devise
class Users::SessionsController < Devise::SessionsController

  include ApplicationHelper

  def create
    super
  end

  def new
    super
  end

end
