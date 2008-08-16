class Video < ActiveRecord::Base

  has_and_belongs_to_many :descriptors

  validates_presence_of :title
  validates_presence_of :sentence
  validates_uniqueness_of :filename
  validate :must_have_valid_path
  validate :must_exist_on_disk
  validate :descriptors_must_be_unique
  
  before_save do |video|
    video.size ||= File.size(video.path)
  end
  
  after_save do |video|
    begin
      vf = VideoFulltext.find_by_video_id video.id
      if vf == nil
        vf = VideoFulltext.new :video_id => video.id
      end
      vf.title = video.title
      vf.year = video.year
      vf.sentence = video.sentence
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

  VIDEO_DIR = ::VIDEO_DIR
  
  def self.list_uncataloged_files
    list = Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.new(filename) }
    list.reject! {|file| Video.exists?(:filename => File.basename(file.path)) }
    list.partition { |file| File.directory?(file) }.flatten!
  end
  
  def path
    File.expand_path(File.join(Video::VIDEO_DIR, filename))
  end
  
  def valid_path?
    video_path = Pathname.new File.expand_path(VIDEO_DIR)
    Pathname.new(File.expand_path(path)).ascend do |path|
      return true if path == video_path
    end
    return false
  end
  
  def self.recent number = nil
    options = { :order => "created_at" }
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
    select = [ "distinct videos.*" ]
    select = [ "videos.*" ]

    if !options[:query].blank?

      # FIX: check for safety ...

      p = options[:query].gsub(/\\/, '\&\&').gsub(/'/, "''") 
      
      select <<
        "match ( vfs.title, vfs.sentence, vfs.year ) against ( '#{p}' ) as r"
      joins << "video_fulltexts vfs"

      p = ( p.split(/\s+/).map { |v| "+" + v } ).join(" ")
        
      conditions[0] <<
        "( match ( vfs.title, vfs.sentence, vfs.year ) " +
          "against ( '#{p}' in boolean mode ))"
      conditions[0] << "(videos.id = vfs.video_id)"
      options[:order] ||= "r desc"
    end
    options.delete :query

    if options[:descriptor_id]
      joins << "descriptors_videos dvs"
      
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

  private

  def must_have_valid_path
    errors.add_to_base("The path must point to a valid file") \
      if !valid_path?
  end

  def must_exist_on_disk
    if valid_path?
      errors.add_to_base("The file does not exist on disk") \
        if !File.exists?(path)
    end
  end

  def descriptors_must_be_unique
    # NB: the join table is generally updated before this gets run
    errors.add( :descriptors, "Duplicate descriptors not allowed" ) \
      if descriptors.uniq != descriptors
  end

end
