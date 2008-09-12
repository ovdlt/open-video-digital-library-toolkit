class CollectionsController < ApplicationController

  before_filter :find_and_verify_public_or_user,
                :except => [ :collections, :playlists, :new, :create ]

  before_filter :find_and_verify_user, :only => [ :edit, :update ]

  before_filter :login, :only => [ :new, :create ]

  def new
    @collection = Collection.new
    render :template => "collections/form"
  end

  def create
    @collection = Collection.new params[:collection]
    @collection.user_id = current_user.id
    if @collection.save
      redirect_to collection_path( @collection.id )
    else
      render :template => "collections/form"
    end
  end

  def edit
    render :template => "collections/form"
  end

  def update
    if @collection.update_attributes params["collection"]
      redirect_to collection_path( @collection.id )
    else
      render :template => "collections/form"
    end
  end

  def collections
    user = User.find Library.collections_user_id;
    @collections =
      Collection.paginate :page => params[:page],
                           :per_page => 5,
                           :conditions => [ "user_id = ? and public is true",
                                            user ]
    @title = Library.collections_title
    @subtitle =
      "The #{Library.title} currently contains "+
      "#{@collections.total_entries} collections"
    render :action => :index
  end

  def playlists
    user = User.find Library.collections_user_id;
    @collections =
      Collection.paginate :page => params[:page],
                           :per_page => 5,
                           :conditions => [ "user_id <> ? and public is true",
                                            user ]
    @collections =
      Collection.paginate :page => params[:page],
                           :per_page => 5,
                           :conditions => [ "public is true" ]
    @title = Library.playlists_title
    render :action => :index
  end

  private

  def find_and_verify_public_or_user
    if !params[:id] or
        !(@collection = Collection.find_by_id params[:id]) or
        (!@collection.public? and
         (!current_user or @collection.user_id != current_user.id))
      render_missing
      return
    end
    
    @collection.views += 1
    @collection.save

  end

  def find_and_verify_user
    if !params[:id] or
        !(@collection = Collection.find_by_id params[:id]) or
        ((!current_user or @collection.user_id != current_user.id))
      render_missing
      return
    end
  end

end
