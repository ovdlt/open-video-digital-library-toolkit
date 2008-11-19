class TaggingController < ApplicationController

  before_filter :load

  def create
    @video.add_tags params[:tags]
    if @video.tags.changed
      @video.save
    end
    redirect_to :back
  end

  private

  def load

    if !current_user
      render_missing
      return
    end

    if !(@video = Video.find_by_id params[:video_id])
      render_bad_request
      return
    end

    if !check_video_viz(@video)
      render_bad_request
      return
    end

  end

end
