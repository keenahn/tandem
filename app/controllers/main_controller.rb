# The main controller for displaying pages on the site
class MainController < ApplicationController

  def index
    if current_user
      return redirect_to groups_path
    else
      render
    end
  end

end
