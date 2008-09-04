class MyController < ApplicationController

  before_filter :login

  def login
    current_user or redirect_to login_path
  end

end
