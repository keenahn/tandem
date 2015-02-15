# The main controller for displaying pages on the site
class MainController < ApplicationController

  def index
    return redirect_to groups_path if current_user
  end

end
