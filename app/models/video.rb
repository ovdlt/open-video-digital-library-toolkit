class Video < ActiveRecord::Base

  # belongs_to :rights

  has_many :assets, :dependent => :destroy

  has_many :properties, :dependent => :destroy do
    def find_all_by_type name
      pt = PropertyType.find_by_name name
      find_all_by_property_type_id( pt ) if pt
    end
  end

  has_many :assignments, :dependent => :destroy
  has_many :descriptors, :through => :assignments

  has_many :bookmarks, :dependent => :destroy
  has_many :collections, :through => :bookmarks

  validates_presence_of :title
  validates_presence_of :sentence

  # validates_presence_of :rights_id, :message => "type must be selected"

  validate :descriptors_must_be_unique
  
  after_save do |video|
    begin
      vf = VideoFulltext.find_by_video_id video.id
      if vf == nil
        vf = VideoFulltext.new :video_id => video.id
      end
      texts = [ video.title,
                video.sentence,
                video.abstract,
                video.donor ]

      video.descriptors.each { |d| texts << d.text }

      vf.text = texts.join(" ")
      vf.save
    end
  end

  after_destroy do |video|
    begin
      vf = VideoFulltext.find_by_video_id video.id
      if vf
        vf.destroy
      end
    end
  end

  # remove when rights table dropped

  def initialize options = {}
    super
    if !self.rights_id
      self.rights_id = 1
    end
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
    ( descriptors.map &:descriptor_type ).uniq.
      sort { |a,b| a.priority - b.priority }
  end

  def descriptors_by_type type
    descriptors.select { |d| d.descriptor_type == type }.
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

    if options[:descriptor_id]
      joins << "assignments dvs"
      
      conditions[0] << "(videos.id = dvs.video_id)"
      
      conditions[0] << "(dvs.descriptor_id = ?)"
      conditions[1] << options[:descriptor_id]
    end
    options.delete :descriptor_id
    
    options[:order] ||= "videos.created_at desc"

    if joins != []
      options[:joins] = "join " + joins.join(", ")
    end

    if conditions != [ [], [] ]
      options[:conditions] =
        [ "(" + conditions[0].join("AND") + ")", conditions[1] ]
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

  private

  def descriptors_must_be_unique
    # NB: the join table is generally updated before this gets run
    errors.add( :descriptors, "Duplicate descriptors not allowed" ) \
      if descriptors.uniq != descriptors
  end

end
