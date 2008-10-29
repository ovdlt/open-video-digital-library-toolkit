module ApplicationHelper

  def rights_details
    @rights_details
  end

  def tab_title string
    string = string.to_s
    string = string.titleize
    string.sub! /^show\s+/i, ""
    string.sub! /^edit\s+/i, ""
    string
  end

  def tabs_tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def tabs_div_for field
    render :partial => "/shared/div", :object => field
  end

  def file_size file
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def sq_path sq
    if sq.descriptor_value
      if !sq.query_string.blank?
        descriptor_value_videos_path( sq.descriptor_value, :query => sq.query_string )
      else
        descriptor_value_videos_path( sq.descriptor_value )
      end
    else
      if !sq.query_string.blank?
        videos_path( :query => sq.query_string )
      else
        videos_path
      end
    end
  end

  def browse_descriptors_and_types video
    descriptors = video.descriptors
    types = ( descriptors.map { |d| d.descriptor_type } ).uniq
    types = DescriptorType.browse.select { |dt| types.include? dt }
    types.map { |t| [ t, descriptors.select { |d| d.descriptor_type == t } ] }
  end

  def property_types_by_class pc
    pcs = Array(pc).map(&:id)
    @property_types.select { |pt| pcs.include? pt.property_class_id }
  end

  def int_to_duration v
    return nil if v.nil?
    return v if String === v
    h = v/3600
    m = ( v % 3600 ) / 60
    s = ( v % 3600 ) % 60
    "%02d:%02d:%02d" % [ h, m, s ]
  end

  def partial
    params[:action].singularize
  end
  
  def mailto collection
    by = User.find_by_id(collection.user_id).login
    subject = url_encode( h( "Playlist entitled #{collection.title} by #{by}" ))
    body = url_encode(h( <<EOS ))
Playlist link: #{collection_url(collection)}
Link to #{Library.title}: #{root_url}
EOS
    "mailto:?subject=#{subject}&amp;body=#{body}"
  end

  def mail_video video
    subject = url_encode( h( "Video entitled #{video.title}" ) )
    body = url_encode( h( <<EOS ) )
Video: #{video_url(video)}
#{Library.title}: #{root_url}
EOS
    "mailto:?subject=#{subject}&amp;body=#{body}"
  end

  def bookmark_options( video )
    options = current_user.collections.map do |c|
      disabled = ""
      if c.video_ids.include? video.id
        disabled = ' disabled="disabled"'
      end
      "<option value=\"#{c.id}\"#{disabled}>#{h c.title}</option>"
    end
    
    options.join("")
  end

  def container_text collection
    collection.user_id == Library.collections_user_id ? "collection" \
                                                       : "playlist"
  end

  def containers_text collection
    container_text( collection ).pluralize
  end

  def owner_text collection
    owner = nil
    if current_user and current_user.id == collection.user_id
      owner = "my"
    elsif collection.user_id != Library.collections_user_id
      owner = collection.user.login
    end
    owner
  end

  def type_id object
    if object
      id = object.id
      if id.nil? or ( @rollback and @new.values.include?(object) )
        begin
          "new_" + object.real_object_id.to_s
        rescue
          "new_" + object.object_id.to_s
        end
      else
        id.to_s
      end
    else
      raise ArgumentError
    end
  end

  def error_class object, method = nil
    if method.nil?
      object.errors.empty? ? {} : { :class => "error" }
    else
      error_message_on( object, method ).blank? ? {} : { :class => "error" }
    end
  end

  def descriptor_types
    pcs = @property_classes.select { |pc| pc.range == "descriptor_value" }.map( &:id )
    @property_types.select { |pt| pcs.include? pt.property_class_id }
  end
  
  def descriptor_values pt
    @descriptor_values.select do |dv|
      dv.property_type == pt or type_id( dv.property_type ) == type_id(pt)
    end
  end

  class Template

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
    end

  end

  class PropertyTypeTemplate < Template
    def initialize helper, pc
      @helper = helper
      @property_class = pc
    end

    def name
      nil
    end

    def property_class_id
      @property_class.id
    end

    def real_object_id
      object_id
    end

    def id
      "new_pt"
    end

  end

  def pt_template property_class
    PropertyTypeTemplate.new self, property_class
  end

  class PropertyTemplate < Template
    def name
      nil
    end
    def property_type_id
      nil
    end
    def value
      nil
    end
    def id
      "new_p"
    end
  end

  def p_template
    PropertyTemplate.new
  end

end
