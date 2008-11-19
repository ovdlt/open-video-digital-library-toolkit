class BookmarksController < ApplicationController

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
    
    collection.alL_videos << video
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

end
