class VideosController < ApplicationController

  before_filter :find_video, :only => [:update,
                                       :edit,
                                       :destroy,
                                       :show,
                                       :download,
                                      ]

  require_role [ :admin, :cataloger], :for_all_except => [ :index,
                                                           :show,
                                                           :recent ]

  def show
    @path = lambda { |opts| opts == {} ? video_path( @video ) \
                                       : video_path( @video, opts ) }


    class << @video
      def record_timestamps; false; end
    end
    
    @video.views += 1
    @video.save

    class << @video
      remove_method :record_timestamps
    end
  end

  def download
    @asset = @video.assets[0]
    if !@asset
      render_missing
      return
    end

    if !@assert.video.public? and
       (!current_user or !current_user.has_role?[:admin,:cataloger])
      render_missing
      return
    end

    if current_user and
       current_user.downloads.videos.find_by_id(@video.id).nil?
      current_user.downloads.videos << @video
      current_user.downloads.save!
      current_user.save!
    end
      
    redirect_to "/assets/" + @asset.relative_path
  end

  def per_page
    return 20
    return 10 if params[:list_format].nil?
    return 16 if params[:list_format] == "tile"
    return 36 if params[:list_format] == "image"
  end

  def recent
    @search = Search.new 
    current_user and @search.user_id = current_user.id
    search
  end

  def index
    if params[:search] or @property_type_menu
      search
    else
      params[:style] = "recent"
      home
    end
  end

  def home
    case params[:style]
    when "recent"
    else
      render_nothing
      return
    end
    render :template => "videos/#{params[:style]}"
  end

  def search

    @videos = Video.search :method => :paginate,
                            :page => params[:page],
                            :per_page => per_page,
                            :search => @search

    render :template => "videos/index"

  end
  
  def cancel
    redirect_to videos_path
  end


  def clear
    redirect_to new_video_path
  end

  def reset
    redirect_to edit_video_path( params[:id] )
  end


  def new
    @video = @object = Video.new
    render :action => "form"
  end

  def create
    @video = Video.new
    _change
  end

  def update
    @path = lambda { |opts| opts == {} ? video_path( @video ) \
                                       : video_path( @video, opts ) }
    @video = Video.find params[:id]
    _change
  end
  
  def _change

    @rollback = false
    @new = {}

    Video.transaction do

      okay = true

      if v = params[:video]
        v[:assets]
        if a = v[:assets]
          a.reject! { |val| val == ":id:" }
          v[:asset_ids] = a.map { |s| s.to_i }
          v.delete(:assets)
        end
        
        okay = false if !@video.update_attributes(v)
      end

      if ps = params[:property]
        ps.each do |p_id,p_params|
          p_ar = @properties.detect { |p_ar| p_ar.id == p_id.to_i }
          if p_ar
            if p_params["deleted"] == "deleted"
              p_ar.destroy
            else
              p_params.delete "deleted"
              # pp p_ar.errors if !p_ar.update_attributes(p_params)
              okay = false if !p_ar.update_attributes(p_params)
            end
          elsif p_id =~ /^new(_[a-z]+)?_\d+$/ and p_params["deleted"] != "deleted"
            p_params.delete "deleted"
            @properties << (p = @video.properties.build p_params)
            @new[p_id] = p
            if !p.save
              okay = false
            end
            # raise p.errors.inspect if !p.save
          elsif p_id !~ /new(_[a-z]+)?/ and p_params["deleted"] != "deleted"
            logger.warn "bad p id: #{p_id}"
            render :nothing => true, :status => 400
            raise ActiveRecord::Rollback
          end
        end

      end

      if params[:new_assets]
        params[:new_assets].each do |uri|
          @video.assets << Asset.new( :uri => uri )
        end
      end

      if dts = params["descriptor_type"]

        dts.each do |dt,dvs|

          dt_id = dt.to_i
          
          if dt_id.nil? or dt_id < 1
            render_bad_request 
            return
          end
          
          current_ids = @properties.select { |p| p.property_type_id == dt_id }.map(&:integer_value)
          on_ids = dvs.select { |k,v| v == "1" }.map { |k,v| k.to_i }
          off_ids = dvs.select { |k,v| v == "no" }.map { |k,v| k.to_i }
          
          turn_on = on_ids - current_ids
          turn_off = off_ids & current_ids
          
          turn_off.each do |dv_id|
            destroy_dv_property( dt_id, dv_id )
          end

          turn_on.each do |dv_id|
            create_dv_property( dt_id, dv_id )
          end

        end

      end

      if params["descriptor_value"]
        @video.descriptors = params["descriptor_value"].map do |d|
          begin
            DescriptorValue.find d.to_i
          rescue ActiveRecord::RecordNotFound
            render_bad_request 
            return
          end
        end
      end

      was_new = @video.new_record?
      
      @video.save

      if okay
        if was_new
          flash[:notice] = "#{@video.title} was added"
          if params["submit"] == "save"
            redirect_to edit_video_path( @video )
          else
            redirect_to videos_path
          end
        else
          flash[:notice] = "#{@video.title} saved"
          if params["submit"] == "save"
            redirect_to edit_video_path( @video )
          else
            redirect_to video_path( @video )
          end
        end
      else
        @rollback = true
        flash[:error] = "Errors exist; could not update"
        render :action => :form
        raise ActiveRecord::Rollback
      end

    end

  end

  def edit
    @object = @video = Video.find( params[:id] )
    render :action => :form
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

  def find_video_for_cat
    @video = nil
    video_id = params[:id]
    if !video_id.nil? and video_id != "0"
      if session["working_video"] and
         session["working_video"].id == video_id.to_i
        @video = session["working_video"]
      else
        session["working_video"] = @video = Video.find( video_id )
      end
    end
    @video ||= ( session["working_video"] ||= Video.new :title => "foobar" )
    @video.id ||= 0
  end

  def handle_category

    find_video_for_cat

    if request.method == :get
      render :layout => false
    elsif request.method == :put and !@video.new_record? or
          request.method == :post and @video.new_record?

      params[:video] and params[:video].each do |k,v|
        @video[k] = v
      end

      if params["descriptors_passed"] && !params["descriptor_value"]
        params["descriptor_value"] = []
      end

      if params["descriptor_value"]
        @video.descriptors = params["descriptor_value"].map do |d|
          begin
            DescriptorValue.find d.to_i
          rescue ActiveRecord::RecordNotFound
            render_bad_request 
            return
          end
        end
      end

      if @video.id == 0
        @video.id = nil
      end

      if params["commit"]
        was_new = @video.new_record?
        if @video.save
          if was_new
            flash[:notice] = "#{@video.title} was added"
            session["working_video"] = nil
            redirect_to videos_path
          else
            flash[:notice] = "#{@video.title} saved"
            redirect_to video_path( @video )
          end
        else
          redirect_to new_video_path
        end
      else
        render :nothing => true
      end
    else
      render_bad_request
    end
  end

  def find_video
    @video = Video.find_by_id(params[:id])
    if @video.nil? or !check_video_viz( @video )
      flash[:error] = "Video could not be found"
      redirect_to videos_path
    end
  end

  private

  before_filter :load

  def load
    @property_classes = PropertyClass.find :all
    @property_types = PropertyType.find :all
    @rights_details = RightsDetail.find :all
    @descriptor_values = DescriptorValue.find :all

    @properties = Property.find_all_by_video_id params[:id]

    @search = Search.new params[:search]
    current_user and @search.user_id = current_user.id
    if params[:search]
      session[:search] = @search
    end

    if ptid = params[:property_type_menu_id]
      @property_type_menu = PropertyType.find_by_id ptid
    end

  end

  def create_dv_property pt_id, dv_id
    @properties << ( p = Property.new( :property_type_id => pt_id,
                                        :integer_value => dv_id,
                                        :video_id => @video.id ) )
    p.save
  end

  def destroy_dv_property pt_id, dv_id
    @properties.reject! { |p| p.property_type_id == pt_id and p.integer_value == dv_id }
    Property.find_by_video_id_and_property_type_id_and_integer_value( @video.id, pt_id, dv_id ).destroy
  end

end
