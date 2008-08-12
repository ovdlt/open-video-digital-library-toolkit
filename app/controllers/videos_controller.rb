class VideosController < ApplicationController
  before_filter :find_video, :only => [:update, :edit, :destroy]
  
  # FIX: page through database

  def index
    @videos = nil
    if params[:descriptor_id]
      @videos = Video.find :all,
                           :joins => "join descriptors_videos dvs on dvs.video_id = videos.id",
                           :conditions => [ "dvs.descriptor_id = ?", params[:descriptor_id] ]
    else
      @videos = Video.find :all
    end
    
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
    if params[:video] && params[:video].include?(:filename) && (params[:video][:filename] != @video.filename)
      render_bad_request 
      return
    end
    
    # This is so if all boxes are unchecked, we actually remove all
    # descriptors

    if params["descriptors_passed"] && !params["descriptor"]
      params["descriptor"] = []
    end

    if params["descriptor"]
      @video.descriptors = params["descriptor"].map do |d|
        begin
          Descriptor.find d.to_i
        rescue ActiveRecord::RecordNotFound
          render_bad_request 
          return
        end
      end
    end

    if @video.update_attributes(params[:video])
      flash[:notice] = "#{@video.filename} was updated"
      redirect_to videos_path
    else
      render :action => 'form'
    end
  end
  
  def destroy
    @video.destroy
    flash[:notice] = "#{@video.title} was deleted"
    redirect_to videos_path
  end
  
  private
  def find_video
    @video = Video.find_by_id(params[:id])
    if @video.nil?
      flash[:error] = "Video could not be found"
      redirect_to videos_path and return
    end
    @video
  end
  
  def render_missing
    render :nothing => true, :status => interpret_status(404)
  end
  
  def render_bad_request
    render :nothing => true, :status => interpret_status(400)
  end
end
