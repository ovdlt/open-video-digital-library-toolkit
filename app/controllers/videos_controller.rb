class VideosController < ApplicationController
  def index
    @videos = Video.find :all
    @files  = Video.list_uncataloged_files
  end
  
  def new
    @video = Video.new(:filename => params[:filename])
    if @video.valid_path?
      render :action => 'form'
    else
      render_missing
    end
  end
  
  def create
    @video = Video.new(:filename => params[:video][:filename], :title => params[:video][:title], :sentence => params[:video][:sentence])
    if @video.save
      flash[:notice] = "#{@video.filename} was added"
      redirect_to videos_path
    else
      render :action => 'form'
    end
  end
  
  def edit
    @video = Video.find params[:id]
    render :action => 'form'
  end
  
  def update
    @video = Video.find(params[:id])
    if params[:video].include?(:filename) && (params[:video][:filename] != @video.filename)
      render_bad_request 
      return
    end
    if @video.update_attributes(params[:video])
      flash[:notice] = "#{@video.filename} was updated"
      redirect_to videos_path
    else
      render :action => 'form'
    end
  end
  
  private
  def render_missing
    render :nothing => true, :status => interpret_status(404)
  end
  
  def render_bad_request
    render :nothing => true, :status => interpret_status(400)
  end
end
