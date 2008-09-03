module VideosHelper

  def tabs
    [
     :general_information,
     :digital_files,
     :responsible_entities,
     :dates,
     :chapters,
     :descriptors,
     :collections,
     :related_videos,
    ]
  end

  def tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def div_for field
    render :partial => "/shared/div", :object => field
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
      ( Rights.find :all ).map do |r|
        [ r.license,
          r.id,
          @video.rights_id == r.id ? { :selected => true  } : {} ]
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

  def int_to_duration v
    return nil if v.nil?
    h = v/3600
    m = ( v % 3600 ) / 60
    s = ( v % 3600 ) % 60
    "%02d:%02d:%02d" % [ h, m, s ]
  end

  private

  def select_options hash
    ( hash.map { |k,v| v ? "#{k}='#{k}'" : "" } ).join(" ")
  end

end
