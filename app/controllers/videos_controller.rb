class VideosController < ApplicationController
  def index
    @videos = Video.find :all
    @files  = Video.list_uncataloged_files
  end
  
  def new
    @video = Video.new(:filename => params[:filename])
    render_missing unless @video.valid_path?
  end
  
  def create
    @video = Video.new(:filename => params[:video][:filename], :title => params[:video][:title], :sentence => params[:video][:sentence])
    if @video.save
      flash[:notice] = "#{@video.filename} was added"
      redirect_to videos_path
    else
      render :template => 'videos/new'
    end
  end
  
  private
  def render_missing
    render :nothing => true, :status => interpret_status(404)
  end
end
