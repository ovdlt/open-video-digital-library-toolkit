class MyController < ApplicationController

  before_filter :login

  def show
    redirect_to home_my_path
  end

  def favorites
    @collection = current_user.favorites params
    @videos = @collection.send(videos_method).paginate :page => params[:page],
                                                       :per_page => 20,
                                                       :order => "bookmarks.created_at desc"
    render :action => "collection"
    # render :template => "collections/show"
  end

  def downloaded_videos
    @collection = current_user.downloads params
    @videos = @collection.send(videos_method).paginate :page => params[:page],
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
    render :template => "my/playlists",
           :locals => { :collections =>
                        @collections = current_user.playlists( params )}
    end
  end

  def password

    @user = current_user

    new_password = params[:new_password]
    confirm_password = params[:confirm_password]

    if new_password != confirm_password
      flash.now[:error] = "password and password confirmation not the same"
      render :action => :my_account
      return
    end

    if new_password.blank?
      flash.now[:error] = "new password cannot be blank"
      render :action => :my_account
      return
    end

    if !@user.authenticated? params[:old_password]
      flash.now[:error] = "password incorrect"
      render :action => :my_account
      return
    end

    @user.password = new_password
    @user.password_confirmation = confirm_password
    @user.save

    if !@user.errors.empty?
      p @user.errors
      flash.now[:error] = "Password #{@user.errors.on :password}"
      render :action => :my_account
      return
    end

    flash[:notice] = "password changed"
    redirect_to url_for( :action => :my_account )
  end

end
