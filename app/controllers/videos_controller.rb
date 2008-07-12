class VideosController < ApplicationController
  def index
    @videos = Video.list_videos
  end
  
  def new
    @video = Video.new(:filename => params[:filename])
    render_missing unless @video.valid_path?
    
  end
  
  private
  def render_missing
    render :nothing => true, :status => interpret_status(404)
  end
end
