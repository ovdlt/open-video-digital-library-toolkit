class VideosController < ApplicationController
  def index
    @videos = Video.list_videos
  end
end
