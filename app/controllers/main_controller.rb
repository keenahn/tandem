# The main controller for displaying pages on the site
class MainController < ApplicationController

  def index
    if current_user
      render "main/index_logged_in"
    else
      render
    end
  end

end
