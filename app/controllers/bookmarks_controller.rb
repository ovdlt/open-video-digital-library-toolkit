class BookmarksController < ApplicationController

  before_filter :find_and_verify_user, :only => [ :update, :annotation ]

  def create
    if  !(params[:video_id]) or
        !(video = Video.find_by_id params[:video_id]) or
        !check_video_viz(video) or
        !(collection_id = params[:bookmark_into_id]) or
        !(collection = Collection.find_by_id collection_id) or
        ((!current_user or collection.user_id != current_user.id))
      render_missing
      return
    end
    
    collection.all_videos << video
    collection.save!

    redirect_to :back

  end

  def destroy
    if  !(params[:video_id]) or
        !(collection = Collection.find_by_id params[:collection_id]) or
        ((!current_user or collection.user_id != current_user.id))
      render_missing
      return
    end
    
    bookmark = 
      Bookmark.find_by_video_id_and_collection_id params[:video_id],
                                                  params[:collection_id]

    if bookmark
      bookmark.destroy
    end

    redirect_to :back

  end

  def annotation
    text = nil
    if @bookmark
      @bookmark.annotation = params[:value]
      @bookmark.save
      @bookmark.reload
      text = @bookmark.annotation
    end
    render :text => text
  end

  def update
    @bookmark.attributes = params[:bookmark]
    @bookmark.save!
    redirect_to :back
  end
  
  def order
    if !current_user
      render_missing
      return
    end

    ids = params["order"].split(/[,\s]+/).map(&:to_i)

    if Bookmark.set_order current_user.id, ids
      render_nothing
    else
      render_missing
    end

  end

  private

  def find_and_verify_user
    if !params[:id] or
        !(@bookmark = Bookmark.find_by_id params[:id]) or
        (!current_user or ( @bookmark.user.id != current_user.id and
                            !current_user.has_role?([:admin,:cataloger]) ))
      render_missing
      return
    end
  end

end
