class DownloadsController < ApplicationController

  def destroy
    if !current_user
      render_missing
      return
    end

    if params[:id].blank? or params[:id] == "0"
      render_missing
      return
    end

    if v = Video.find( params[:id] )
      current_user.downloads.all_videos.delete v
      flash[:notice] = "Download removed"
    end

    redirect_to :back
  end

end
