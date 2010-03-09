module ApplicationHelper

  def property_type_videos_path t
    videos_path :property_type_menu_id => t.id
  end

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

  def tabs_div2_for field
    render :partial => "/shared/div2", :object => field
  end

  def tabs_div3_for field
    render :partial => "/shared/div3", :object => field
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
  
  def search_path search
    videos_path search.add_to_params( {}, :search )
  end

  def browse_descriptors_and_types video
    properties = video.properties
    types = ( properties.map { |d| d.property_type } ).uniq
    types = PropertyType.browse.select { |dt| types.include? dt }
    types.map { |t| [ t, properties.select { |d| d.property_type == t } ] }
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

  def mail_video_issue video
    subject = url_encode( h( "Issues with video entitled #{video.title}" ) )
    body = url_encode( h( <<EOS ) )
Video: #{video_url(video)}
#{Library.title}: #{root_url}

Issue:
EOS
    to = @library.emails
    # to.tr! ",", " "
    # to.tr! ";", " "
    "mailto:#{url_encode(@library.emails)}?subject=#{subject}&amp;body=#{body}"
  end

  def bookmark_options( video )
    options = current_user.collections.map do |c|
      disabled = ""
      if c.send(video_ids_method).include? video.id
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
    pcs = @property_classes.select { |pc| pc.range_type == "descriptor_value" }.map( &:id )
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

  def descriptor_value_search dv
    search = Search.new
    search.criteria <<
      Criterion.new( :property_type_id => dv.property_type_id,
                      :integer_value => dv.id )
    search_path search
  end

  def featured_videos
    Video.find :all, :conditions => { :featured => true }.merge( viz_condition ),
                      :order => "featured_priority desc, featured_on desc"
  end

  def featured_collections
    Collection.find :all, :conditions => { :featured => true }.merge( viz_condition ),
                            :order => "featured_priority desc, featured_on desc"
  end

  def feature_rank object
    klass = object.class
    total = klass.count :conditions => { :featured => true }.
                                                merge( viz_condition )
    objects = klass.find :all, :conditions => { :featured => true }.
                                                merge( viz_condition ),
                             :order => "featured_priority desc, featured_on desc"
    i = 1
    objects.each do |v|
      if v == object
        break
      end
      i+=1
    end
    "(#{i} of #{total})"
  end

  def video_created video
    created =  PropertyType.find_by_name( "Creation" )
    date = nil
    if created
      if p = video.properties.find_by_property_type_id( created.id )
        date = p.value
      end
    else
      date = video.created_at
    end
    date ? date.to_date : nil
  end

  def collections_flag
    if CollectionsController === controller 
      if params[:action] == "collections"
        "on"
      elsif params[:id]
        collection = Collection.find params[:id]
        ( collection and collection.user.login == @library.collections_login ) ? "on" : "off"
      else
        "off"
      end
    end
  end

  def playlists_flag
    if CollectionsController === controller 
      collections_flag == "off" ? "on" : "off"
    else
      "off"
    end
  end

  def viz_condition
    ( current_user and
      current_user.has_role?([:admin,:cataloger]) ) ? {} : { :public => true }
  end

  def video_vis_class v
    v.public? ? "public" : "private"
  end

  def videos_method
    public_only? ? :public_videos : :all_videos
  end

  def bookmarks_method
    public_only? ? :public_bookmarks : :all_bookmarks
  end

  def video_ids_method
    public_only? ? :public_video_ids : :all_video_ids
  end

  def public_only?
    begin
      !current_user or !current_user.has_role?([:admin,:cataloger])
    rescue
      true
    end
  end

  def tags_html tags
    tags = tags.to_a
    tags.map! do |tag|
      link_to h(tag.text), search_path( Search.new( :tag => tag.id ) )
    end
    tags.join(", ")
  end

  # Not thread safe, for what it's worth

  @@id = 0

  def gen_id
    "gen_id_#{@@id+=1}"
  end

end
