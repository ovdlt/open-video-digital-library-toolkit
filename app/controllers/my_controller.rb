class MyController < ApplicationController

  before_filter :login

  def show
    redirect_to favorites_my_path
  end

  def favorites
    render :template => "collections/show",
           :locals => { :collection => @collection = current_user.favorites }
  end

  def downloaded_videos
    render :template => "collections/show",
           :locals => { :collection => @collection = current_user.downloads }
  end

  def playlists
    @title = "#{current_user.login} Playlists"
    render :template => "collections/index",
           :locals => { :collections =>
                        @collections = current_user.playlists( params )}
  end

end
