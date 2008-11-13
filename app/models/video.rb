class Video < ActiveRecord::Base

  has_many :assets, :dependent => :destroy

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

    vf.text = texts.join(" ")
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

  def descriptors
    ids = PropertyClass.find_all_by_range "descriptor_value"
    (properties.find_all_by_property_class_id ids).freeze
  end

  def descriptors= descriptors
    ids = PropertyClass.find_all_by_range "descriptor_value"
    (properties.find_all_by_property_class_id ids).each {|p| p.destroy}
    descriptors.each { |d| properties << d }
  end

  def self.recent number = nil
    options = { :order => "created_at desc" }
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

  def self._search options = {}

    options = options.dup
    
    method = options[:method] || :find
    options.delete :method

    if method == :paginate
      options[:page] ||= nil
    end

    conditions = [ [], [] ]
    joins = []
    select = [ "videos.*" ]

    if !options[:query].blank?

      # FIX: check for safety ...

      p = options[:query].gsub(/\\/, '\&\&').gsub(/'/, "''") 
      
      select <<
        "match ( vfs.text ) against ( '#{p}' ) as r"
      joins << "video_fulltexts vfs"

      p = ( p.split(/\s+/).map { |v| "+" + v } ).join(" ")
        
      conditions[0] <<
        "( match ( vfs.text ) " +
          "against ( '#{p}' in boolean mode ))"
      conditions[0] << "(videos.id = vfs.video_id)"
      options[:order] ||= "r desc"

    end
    options.delete :query

    if options[:descriptor_value_id]
      joins << "properties dvs"
      
      conditions[0] << "(videos.id = dvs.video_id)"
      
      conditions[0] << "(dvs.integer_value = ?)"
      conditions[1] << options[:descriptor_value_id]

      dv = DescriptorValue.find options[:descriptor_value_id]
      
      conditions[0] << "(dvs.property_type_id = ?)"
      conditions[1] << dv.property_type_id
    end
    options.delete :descriptor_value_id
    
    options[:order] ||= "videos.created_at desc"

    if joins != []
      options[:joins] = "join " + joins.join(", ")
    end

    if conditions != [ [], [] ]
      options[:conditions] =
        [ "(" + conditions[0].join("AND") + ")" ] + conditions[1]
    end

    options[:select] = select.join(", ")

    self.send method, :all, options

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

    options[:search].criteria.each do |criterion|

      case criterion.criterion_type.to_s
      when "text"

        # FIX: check for safety of sql escaping

        p = criterion.text.gsub(/\\/, '\&\&').gsub(/'/, "''") 
        
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
    if String === duration
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
    if String === duration
      new_value = nil
      if ( m = duration.match( DURATION_REGEX ) )
        new_value = ((m[1].to_i*60)+m[2].to_i)*60+m[3].to_i
      end
      update_attribute( :duration, new_value )
    end
  end

  def save_rights
    if @rights_property and @rights_property.changed?
      @rights_property.video_id = id
      @rights_property.save
    end
  end

end
