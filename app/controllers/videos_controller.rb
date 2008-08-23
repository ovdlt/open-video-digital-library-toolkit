class VideosController < ApplicationController

  before_filter :find_video, :only => [:update, :edit, :destroy]

  require_role "admin", :for_all_except => [ :index, :show ]

  def show
    @video = Video.find( params[:id] ) if params[:id]
    if !@video
      render_missing
      return
    end
    @path = lambda { |opts| opts == {} ? video_path( @video ) \
                                       : video_path( @video, opts ) }
  end

  def per_page
    return 10 if params[:list_format].nil?
    return 16 if params[:list_format] == "tile"
    return 36 if params[:list_format] == "image"
  end

  def index

    # FIX: number of videos selected depends on the format

    if params[:descriptor_type_id]
      @current = @type = DescriptorType.find( params[:descriptor_type_id] )
    end

    @path = lambda { |opts| videos_path( opts ) }
    
    if params[:descriptor_id]
      @current = @descriptor = Descriptor.find( params[:descriptor_id] )
      @type = @descriptor.descriptor_type
      @path = lambda do |opts|
        descriptor_videos_path( @descriptor, opts )
      end
    end
    
    @videos = Video.search :method => :paginate,
                            :page => params[:page],
                            :per_page => per_page,
                            :query => params[:query],
                            :descriptor_id => params[:descriptor_id]

  end
  
  # FIX: this isn't tested seperately; might go away
  def _manage
    index
    @files  = Asset.list_uncataloged_files
  end

  def _new
    @video = Video.new
    @asset = Asset.new(:uri => "file:///" + params[:filename])
    if @asset.valid_path?
      @video.assets << @asset
      render :action => 'form'
    else
      render_missing
    end
  end
  
  def new
    @video = ( session["working_video"] ||= Video.new :title => "foobar" )
    @video.id ||= 0
    @object = @video
  end

  def create
    @video = Video.new(:title => params[:video][:title],
                       :sentence => params[:video][:sentence])
    @video.assets << Asset.new(:uri => "file:///" + params[:video][:filename])

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

    if @video.save
      flash[:notice] = "#{@video.title} was added"
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
    if params[:video] &&
       params[:video].include?(:filename) &&
       ( params[:video][:filename].nil? or
         ( "file:///" + params[:video][:filename] != @video.assets[0].uri ) )
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
      flash[:notice] = "#{@video.title} was updated"
      redirect_to video_path( @video )
    else
      render :action => 'form'
    end
  end
  
  def destroy
    @video.destroy
    flash[:notice] = "#{@video.title} was deleted"
    redirect_to videos_path
  end
  
  before_filter :handle_category,
                :only => [ :general_information,
                           :digital_files,
                           :responsible_entities,
                           :dates,
                           :chapters,
                           :descriptors,
                           :collections,
                           :related_videos ]
  
  private

  def handle_category
    @video = nil
    video_id = params[:video_id]
    if !video_id.nil? and video_id != "0"
      @video = Video.find video_id
    end
    @video ||= ( session["working_video"] ||= Video.new :title => "foobar" )
    @video.id ||= 0
    case request.method
    when :get;
      render :layout => false
    when :post;
      params[:video].each do |k,v|
        @video[k] = v
      end
      render :nothing => true
    else
      render_bad_request
    end
  end

  def find_video
    @video = Video.find_by_id(params[:id])
    if @video.nil?
      flash[:error] = "Video could not be found"
      redirect_to videos_path and return
    end
    @video
  end
  
end
