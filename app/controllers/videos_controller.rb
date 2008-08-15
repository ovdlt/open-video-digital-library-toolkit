class VideosController < ApplicationController

  before_filter :find_video, :only => [:update, :edit, :destroy]
  
  require_role "admin", :for_all_except => [ :index, :show ]

  def index

    @videos = nil

    # FIX: number of videos selected depends on the format

    if params[:descriptor_type_id]
      @current = @type = DescriptorType.find( params[:descriptor_type_id] )
    end

    conditions = [ [], [] ]
    joins = []
    order = "videos.created_at desc"
    options = { :page => params[:page] }
    select = [ "distinct videos.*" ]
    select = [ "videos.*" ]

    @path = videos_path

    if !params[:query].blank?
      # FIX: check for safety ...
      p = params[:query].gsub(/\\/, '\&\&').gsub(/'/, "''") 
      p = ( p.split(/\s+/).map { |v| "+" + v } ).join(" ")
      
      select <<
        "match ( vfs.title, vfs.sentence, vfs.year ) against ( '#{p}' ) as r"
      joins << "video_fulltexts vfs"

      conditions[0] <<
        "(match ( vfs.title, vfs.sentence, vfs.year ) against ( '#{p}' in boolean mode ))"
      conditions[0] << "(videos.id = vfs.video_id)"
      order = "r desc"
    end

    if params[:descriptor_id]

      @current = @descriptor = Descriptor.find( params[:descriptor_id] )
      @type = @descriptor.descriptor_type
      @path = descriptor_videos_path( @descriptor )

      joins << "descriptors_videos dvs"
      
      conditions[0] << "(videos.id = dvs.video_id)"
      
      conditions[0] << "(dvs.descriptor_id = ?)"
      conditions[1] << params[:descriptor_id]
      
    end
    
    options[:order] = order

    if joins != []
      options[:joins] = "join " + joins.join(", ")
    end

    if conditions != [ [], [] ]
      options[:conditions] =
        [ "(" + conditions[0].join("AND") + ")", conditions[1] ]
    end

    options[:select] = select.join(", ")

    @videos = Video.paginate :all, options

  end
  
  # FIX: this isn't tested seperately; might go away
  def manage
    index
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
