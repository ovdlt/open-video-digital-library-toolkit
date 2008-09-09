class CollectionsController < ApplicationController

  before_filter :find_and_verify_public_or_user,
                :except => [ :library, :playlists ]

  def library
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
    end
    
    @collection.views += 1
    @collection.save

  end

end
