class HomeController < ApplicationController

  def index
    render :template => "home/recent"
  end

end
