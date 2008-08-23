class AssetsController < ApplicationController

  def new
    @video = params["video_id"].to_i == 0 ? session["new_video"] \
                                          : Video.find( params["video_id"] )
    p @video
    @files  = Asset.list_uncataloged_files
  end

end
