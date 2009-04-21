class Video < ActiveRecord::Base

  has_many :assets, :dependent => :destroy

  has_many :taggings
  has_many :tags, :through => :taggings

  has_many :properties, :dependent => :destroy do

    def << v
      v = ( DescriptorValue === v ) ? Property.new( v ) : v
      super v
    end

    def find_by_type name
      pt = PropertyType.find_by_name name
      find_by_property_type_id( pt ) if pt
    end

    def find_all_by_type name
      pt = PropertyType.find_by_name name
      find_all_by_property_type_id( pt ) if pt
    end

    def find_all_by_property_type pt
      find_all_by_property_type_id( pt.id )
    end

    def find_all_by_class name

      pc = PropertyClass.find_by_name name

      if pc
        pts = PropertyType.find_all_by_property_class_id pc.id
        return find_all_by_property_type_id( pts ) if pts and !pts.empty?
      end

      []

    end

    def find_all_by_property_class_id ids

      pts = PropertyType.find_all_by_property_class_id ids
      return find_all_by_property_type_id( pts ) if pts and !pts.empty?

      []

    end

  end

  has_many :property_types, :through => :properties

  has_many :bookmarks, :dependent => :destroy
  has_many :collections, :through => :bookmarks

  validates_presence_of :title
  validates_presence_of :sentence

  validate :property_constraints
  validate :validate_duration
  
  before_save do |video|
    video.send :convert_duration
    video.send :update_featured_on
  end

  before_save do |video|
    if video.featured and video.changed.include?( "featured" ) and !video.changed.include?( "featured_priority" )
      video.featured_priority = Video.maximum("featured_priority");
    end
  end

  after_save do |video|

    video.send :save_rights

    vf = VideoFulltext.find_by_video_id video.id

    if vf == nil
      vf = VideoFulltext.new :video_id => video.id
    end

    texts = [ video.title,
              video.sentence,
              video.abstract,
              video.donor,

              video.alternative_title,
              video.series_title,
              video.creation_credits,
              video.participation_credits,
            ]

    # video.descriptors.each { |d| texts << d.text }

    video.properties.each { |p| texts << p.value }

    video.tags.each { |tag| texts << tag.text }

    texts = texts.join(" ")

    texts.tr!("_*?@-+^~%{}:;<>'\"()|.", " ")

    vf.text = texts
    vf.save
  end

  after_destroy do |video|
    begin
      vf = VideoFulltext.find_by_video_id video.id
      if vf
        vf.destroy
      end
    end
  end

  def tag_string
    tags.map {|t| h(t.text) }.join(", ")
  end

  def add_tags tags
    tags = tags.split(",")
    tags.map! {|tag| tag.downcase.strip.gsub(/\s+/, " ") }
    tags.each do |text|
      next if text.blank?
      tag = Tag.find_by_text text
      if !tag
        tag = Tag.new :text => text
      end
      if tag and !tag.new_record? and self.tags.find_by_id( tag.id )
        tag = nil
      end
      if tag
        self.tags << tag
      end
    end
  end

  def update_tags string
    self.tags.clear
    add_tags string
    true
  end

  def descriptors
    ids = PropertyClass.find_all_by_range "descriptor_value"
    (properties.find_all_by_property_class_id ids).freeze
  end

  def descriptors= descriptors
    ids = PropertyClass.find_all_by_range "descriptor_value"
    (properties.find_all_by_property_class_id ids).each {|p| p.destroy}
    descriptors.each { |d| properties << d }
  end

  def self.recent public, number = nil
    options = { :order => "created_at desc" }
    if public
      options.merge! :conditions => { :public => true }
    end
    if number
      options[:limit] = number
    end
    self.find :all, options
  end

  def self.popular public, number = nil
    options = { :order => "views desc" }
    if public
      options.merge! :conditions => { :public => true }
    end
    if number
      options[:limit] = number
    end
    self.find :all, options
  end

  def self.random public, number = nil
    options = { :order => "rand()" }
    if public
      options.merge! :conditions => { :public => true }
    end
    if number
      options[:limit] = number
    end
    self.find :all, options
  end

  def self.per_page
    10
  end

  def descriptor_types
    ( descriptors.map &:property_type ).uniq.
      sort { |a,b| a.priority - b.priority }
  end

  def properties_by_type type
    properties.select { |d| d.property_type == type }.
      sort { |a,b| a.priority - b.priority }
  end

  def self.search options = {}

    options = options.dup
    
    method = options[:method] || :find
    options.delete :method

    if method == :paginate
      options[:page] ||= nil
    end

    conditions = [ [], [] ]
    joins = []
    select = [ "videos.*" ]

    user_id = options[:search][:user_id]
    user = User.find_by_id user_id
    if user.nil? or !user.has_role? [ :admin, :cataloger ]
      conditions[0] << "videos.public = true"
    end

    options[:search].criteria.each do |criterion|

      case criterion.criterion_type.to_s
      when "text"

        # FIX: check for safety of sql escaping

        p = criterion.text

        p.tr!("_*?@-+^~%{}:;<>'\"()|.", " ")
        
        p.gsub!(/\\/, '\&\&')
        p.gsub!(/'/, "''") 
        
        select << "match ( vfs.text ) against ( '#{p}' ) as r"
        joins << "video_fulltexts vfs"

        # FIX: only add + if not there; don't add if starts with -
        p = ( p.split(/\s+/).map { |v| "+" + v } ).join(" ")
        
        conditions[0] <<
          "( match ( vfs.text ) " +
          "against ( '#{p}' in boolean mode ))"
        conditions[0] << "(videos.id = vfs.video_id)"
        options[:order] ||= "r desc"

      when "property_type"

        conditions[0] <<
          "exists ( select * from properties dvs where dvs.video_id = videos.id and " +
          "dvs.integer_value = ? and " +
          "dvs.property_type_id = ? )"
        conditions[1] << criterion.integer_value
        conditions[1] << criterion.property_type_id

      when "public"

        if [ true, false ].include?( criterion.public ) and
            !user.nil? and user.has_role? [ :admin, :cataloger ]
          conditions[0] << "videos.public = ?"
          conditions[1] << criterion.public
        end

      when "tag"

        if tag = Tag.find_by_id( criterion.tag )
          joins << "taggings"
          conditions[0] << "taggings.tag_id = ? and  taggings.video_id = videos.id"
          conditions[1] << tag.id
        end

      when "duration"

        range = [ [-1,1], [1,2], [2,5], [5,10], [10,30], [30,60], [60,-1] ]

        d = criterion.duration.to_i

        lower, upper = range[d]

        if lower > 0
          conditions[0] << "(videos.duration > ?)"
          conditions[1] << lower*60
        end

        if upper > 0
          conditions[0] << "(videos.duration <= ?)"
          conditions[1] << upper*60
        end

      else raise "not implemented: #{criterion.criterion_type}"
      end

    end

    options.delete :search
    
    options[:order] ||= "videos.created_at desc"

    if joins != []
      joins = joins.uniq
      options[:joins] = ", " + joins.join(", ")
    end

    if conditions != [ [], [] ]
      options[:conditions] =
        [ "(" + conditions[0].join(")AND(") + ")" ] + conditions[1]
    end

    options[:select] = select.join(", ")

    self.send method, :all, options

  end

  def poster_path
    @poster_path ||=
      begin
        paths = assets.map(&:relative_path)
        paths = paths.map do |path|
          Dir.glob("#{Asset::SURROGATE_DIR}/#{path}/stills/*_poster*")
        end
        paths.flatten!
        if paths.size > 0
          path = paths[0]
          ( ActionController::Base.relative_url_root or "" ) +
            path[Asset::SURROGATE_PREFIX.length,path.length]
        else
          nil
        end
      end
  end

  def flash_path
    @flash_path ||=
      begin
        paths = assets.map(&:relative_path)
        paths = paths.map do |path|
          Dir.glob("#{Asset::SURROGATE_DIR}/#{path}/flash/*")
        end
        paths.flatten!
        if paths.size > 0
          path = paths[0]
          ( ActionController::Base.relative_url_root or "" ) +
            path[Asset::SURROGATE_PREFIX.length,path.length]
        else
          nil
        end
      end
  end

  def fast_forward_path
    @fast_forward_path ||=
      begin
        paths = assets.map(&:relative_path)
        paths = paths.map do |path|
          Dir.glob("#{Asset::SURROGATE_DIR}/#{path}/fastforwards/*")
        end
        paths.flatten!
        if paths.size > 0
          path = paths[0]
          ( ActionController::Base.relative_url_root or "" ) +
            path[Asset::SURROGATE_PREFIX.length,path.length]
        else
          nil
        end
      end
  end

  def excerpt_path
    @excerpt_path ||=
      begin
        paths = assets.map(&:relative_path)
        paths = paths.map do |path|
          Dir.glob("#{Asset::SURROGATE_DIR}/#{path}/excerpts/*")
        end
        paths.flatten!
        if paths.size > 0
          path = paths[0]
          ( ActionController::Base.relative_url_root or "" ) +
            path[Asset::SURROGATE_PREFIX.length,path.length]
        else
          nil
        end
      end
  end

  def storyboard
    @storyboard ||=
      begin
        paths = assets.map(&:relative_path)
        paths = paths.map do |path|
          Dir.glob("#{Asset::SURROGATE_DIR}/#{path}/stills/*")
        end
        paths.flatten!
        if paths.size > 0
          paths = paths.map do |path|
          ( ActionController::Base.relative_url_root or "" ) +
            path[Asset::SURROGATE_PREFIX.length,path.length]
          end
          paths.sort! do |a,b|
            a.match( /_(\d+\.\d+)[._][^\/]*$/ )[1].to_f <=>
            b.match( /_(\d+\.\d+)[._][^\/]*$/ )[1].to_f
          end
          paths
        else
          nil
        end
      end
  end

  def rights
    @rights_property and @rights_property.value or properties.find_by_name( "Rights Statement" ).value
  end

  def rights_id
    p = @rights_property || properties.find_by_name( "Rights Statement" )
    if p
      p.integer_value
    else
      nil
    end
  end

  # Note: doesn't do any validation, just as the native rails assoc don't

  def rights_id= v
    if @rights_property.nil?
      @rights_property = properties.find_by_name( "Rights Statement" )
    end
    if @rights_property.nil?
      @rights_property =
        Property.new :video_id => id,
                      :property_type_id => PropertyType.find_by_name( "Rights Statement" ).id
      properties << @rights_property
    end
    if @rights_property.integer_value != v
      @rights_property.integer_value = v
    end
  end

  def featured_on
    v = read_attribute :featured_on
    if v.blank?
      v = self.updated_at
    end
    v
  end

  private

  def descriptors_must_be_unique
    # NB: the join table is generally updated before this gets run
    if descriptors.uniq != descriptors
      errors.add( :descriptors, "Duplicate descriptors not allowed" )
    end

  end
  
  def property_constraints
    PropertyType.validate_object self
  end

  DURATION_REGEX = %r{^\s*(\d\d?):(\d\d?):(\d\d?)\s*$} 

  def validate_duration
    duration = attributes_before_type_cast["duration"]
    if String === duration and self.duration.to_s != duration
      if duration !~ DURATION_REGEX
        errors.add :duration, "#{duration} is not a valid duration"
      end
      false
    else
      true
    end
  end

  def convert_duration
    duration = attributes_before_type_cast["duration"]
    if String === duration and self.duration.to_s != duration
      new_value = nil
      if ( m = duration.match( DURATION_REGEX ) )
        new_value = ((m[1].to_i*60)+m[2].to_i)*60+m[3].to_i
      end
      # update_attribute( :duration, new_value )
      attributes["duration"] = new_value
    end
  end

  def update_featured_on
    if featured? and featured_changed?
      self.featured_on = Time::now
    end
  end

  def save_rights
    if @rights_property and @rights_property.changed?
      @rights_property.video_id = id
      @rights_property.save
    end
  end

end
