class CollectionsController < ApplicationController

  before_filter :find_and_verify_public_or_user,
                :except => [ :collections,
                             :playlists,
                             :new,
                             :create,
                             :featured_order,
                             :edit,
                             :update,
                             :desroy ]

  before_filter :find_and_verify_user, :only => [ :edit,
                                                  :update,
                                                  :desroy ]

  before_filter :login, :only => [ :new, :create, :featured_order ]

  require_role [ :admin ], :for => [ :featured_order ]

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

  def destroy
    if current_user.favorites_id == @collection.id
      current_user.favorites_id = nil
      current_user.save!
    elsif current_user.downloads_id == @collection.id
      current_user.downloads_id = nil
      current_user.save!
    end
    @collection.destroy
    redirect_to my_url
  end

  def update
    if current_user.special_collection? @collection
      params["collection"] and params["collection"].delete "title"
    end

    @collection.attributes = params["collection"]

    if @collection.changed == [ "featured" ]
      saved = @collection.trivial_save
    else
      saved = @collection.save
    end
    if saved
      if params[:commit] == "Done"
        redirect_to collection_path( @collection )
      else
        redirect_to :back
      end
    else
      render :template => "collections/form"
    end
  end

  def collections
    user = User.find_by_login Library.collections_login;
    per_page = 5
    if params[:page] == "all"
      params[:page] = 1
      per_page = 9999
    end
    @collections =
      Collection.paginate :page => params[:page],
                           :per_page => per_page,
                           :conditions => [ "user_id = ? and public is true",
                                            user ]
    @title = Library.collections_title
    @subtitle =
      "The #{Library.title} currently contains "+
      "#{@collections.total_entries} special collections"
    render :action => :collections
  end

  def playlists
    user = User.find_by_login Library.collections_login;
    per_page = 5
    if params[:page] == "all"
      params[:page] = 1
      per_page = 9999
    end
    @collections =
      Collection.paginate :page => params[:page],
                           :per_page => per_page,
                           :conditions => [ "user_id <> ? and public is true",
                                            user ]
    @title = Library.playlists_title
    @subtitle =
      "The #{Library.title} currently contains "+
      "#{@collections.total_entries} public playlists"
    render :action => :playlists
  end

  def featured_order
    ids = params["order"].split(/[,\s]+/).map(&:to_i)
    Collection.featured_order = ids
    render_nothing
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
    @collection.trivial_save

    per_page = 5
    if params[:page] == "all"
      params[:page] = 1
      per_page = 9999
    end

    @bookmarks = @collection.send(bookmarks_method).paginate :page => params[:page],
                                                             :per_page => per_page
  end

  def find_and_verify_user
    if !params[:id] or
        !(@collection = Collection.find_by_id params[:id]) or
        (!current_user or ( @collection.user_id != current_user.id and
                            !current_user.has_role?([:admin,:cataloger]) ))
      render_missing
      return
    end
  end

end
