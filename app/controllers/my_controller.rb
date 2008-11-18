class MyController < ApplicationController

  before_filter :login

  def show
    redirect_to home_my_path
  end

  def favorites
    @collection = current_user.favorites params
    @videos = @collection.videos.paginate :page => params[:page],
                                          :per_page => 20,
                                          :order => "bookmarks.created_at desc"
    render :action => "collection"
    # render :template => "collections/show"
  end

  def downloaded_videos
    @collection = current_user.downloads params
    @videos = @collection.videos.paginate :page => params[:page],
                                          :per_page => 20,
                                          :order => "bookmarks.created_at desc"
    render :action => "collection"
    if false
    render :template => "collections/show",
           :locals => { :collection => @collection = current_user.downloads }
    end
  end

  def playlists
    @title = "#{current_user.login} Playlists"
    @collections = current_user.playlists( params )
    if false
    render :template => "collections/index",
           :locals => { :collections =>
                        @collections = current_user.playlists( params )}
    end
  end

end
