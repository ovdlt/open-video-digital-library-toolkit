class HomeController < ApplicationController

  # caches_page :index

  def index
    render :template => "home/recent"
  end

end
