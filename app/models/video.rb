class Video < ActiveRecord::Base

  has_and_belongs_to_many :descriptors

  VIDEO_DIR = ::VIDEO_DIR
  
  validates_presence_of :title
  validates_presence_of :sentence
  validates_uniqueness_of :filename
  validate :must_have_valid_path
  validate :must_exist_on_disk
  validate :descriptors_must_be_unique
  
  def self.list_uncataloged_files
    list = Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.new(filename) }
    list.reject! {|file| Video.exists?(:filename => File.basename(file.path)) }
    list.partition { |file| File.directory?(file) }.flatten!
  end
  
  def before_save
    self.size ||= File.size(path)
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
