module VideosHelper

  def edit_tabs
    [
     :edit_general_information,
     :edit_digital_files,
     :edit_responsible_entities,
     :edit_dates,
     # :edit_chapters,
     :edit_descriptors,
     # :edit_collections,
     # :edit_related_videos,
    ]
  end

  def show_tabs
    [
     :show_dates,
     :show_responsible_entities,
     :show_descriptors,
    ]
  end

  def tab_path tab
    if @object
      send( [ tab.to_s,
              "_",
              controller.controller_name.singularize,
              "_path" ].join("").to_sym, @object )
    else
      send( [ tab.to_s,
              "_",
              controller.controller_name.singularize,
              "_path" ].join("").to_sym )
    end
  end

  def link_to_add_video(file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    # unless Asset.exists?(:uri => "file:///" + File.basename(file.path)) ||
    #   file.stat.directory?
    link_to("add", new_video_path(:filename => File.basename(file.path)))
  end

  def page_format
    ( params[:list_format] || :list ).to_sym
  end


  # rework ... "image" class being used for too many things
  def class_from_format format
    s = format.to_s
    s == "image" ? "images" : s
  end

  def details_format
    ( params[:details_format] || :details ).to_sym
  end

  def current format
    if format == page_format
      {:class => "current"}
    else
      {}
    end
  end

  def link_to_format format
    s = "#{format.to_s.capitalize} View"
    if format == page_format
      "#{format.to_s.capitalize} View"
    else
      link_to s, @path.call( format == :list ? {} : { :list_format => format })
    end
  end

  def link_to_details details
    s = details.to_s.humanize.split.map(&:capitalize).join(" ")
    if details == details_format
      s
    else
      link_to s, @path.call( details == :details ?
                                              {} :
                                              { :details_format => details })
    end
  end

  def rights_options
    options =
      [ [ "Select from the following ...", nil,
          { :disabled => true, :selected => @video.rights_id.nil? } ] ] +
      ( RightsDetail.find :all ).map do |r|
        [ r.license,
          r.id,
          @video.rights.id == r.id ? { :selected => true  } : {} ]
      end
    ( options.map do |o|
        "<option value='#{o[1]}' #{select_options(o[2])}>#{o[0]}</option>"
    end ).join("\n")
  end

  def assets_json
    result = @video.assets.map do |a|
      hash = {}
      [ :id, :uri, [ :size, :file_size ], :asset_format ].each do |field|
        case field
        when Symbol; hash[field] = a.send( field )
        when Array; hash[field[0]] = send( field[1], a )
        end
      end
      hash
    end
    result.to_json
  end

  private

  def render_partial_by_class class_name, title
    range = PropertyClass.find_by_name( class_name ).range
    render :partial => "show_properties_#{range}",
           :locals => { :property_class => class_name,
                        :title => title }
  end

  def render_partial_edit_by_class class_name
    range = PropertyClass.find_by_name( class_name ).range
    render :partial => "edit_properties_#{range}",
           :locals => { :property_class => class_name }
  end

  def select_flash_path video
    case params[:details_format]
    when "fast_forward"; video.fast_forward_path
    when "excerpt"; video.excerpt_path
    else; video.flash_path
    end
  end

  def select_options hash
    ( hash.map { |k,v| v ? "#{k}='#{k}'" : "" } ).join(" ")
  end

  def random descriptor, shown
    videos = descriptor.videos
    return nil if videos.size == 0
    candidates = descriptor.videos.map( &:id ) - shown.keys
    return nil if candidates.size == 0
    selected = rand( candidates.size )
    shown[candidates[selected]] = true
    Video.find candidates[selected]
  end

  def properties_by_class pc
    types = property_types_by_class( pc ).map &:id
    @properties.select do |p|
      types.include? p.property_type_id
    end
  end

  def properties_by_type pt
    @properties.select { |p| pt.id == p.property_type_id }
  end
  
  def video_has_dv dv
    ps = @properties.select { |p| p.property_type_id == dv.property_type_id and
                                  p.integer_value == dv.id }
    !ps.empty?
  end

  def date_range_select fields, object
    if false
      fields.select :property_type_id,
        options_from_collection_for_select( date_types, :name, :id, object.id )
    else
      fields.collection_select :property_type_id, date_types, :id, :name
    end
  end

  def _section_for field
    render :partial => "/shared/tab", :object => field
  end

  def select_options_for_duration selected
    options_for_select [["- any duration -", nil],
                        ["short"],
                        ["medium"],
                        ["long"]],
                        selected
                         
  end

  def select_options_for_type type, selected
    options_from_collection_for_select type.values,
                                       :id,
                                       :text,
                                       selected

                      
  end

  def descriptor_value_search dv
    search = Search.new
    search.criteria <<
      Criterion.new( :property_type_id => dv.property_type_id,
                      :integer_value => dv.id )
    search_path search
  end

  def search_path search
    videos_path search.add_to_params( {}, :search )
  end

end
