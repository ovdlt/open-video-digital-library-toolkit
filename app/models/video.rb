class Video < ActiveRecord::Base
  VIDEO_DIR = "#{RAILS_ROOT}/videos"
  
  validates_presence_of :title
  validates_presence_of :sentence
  validate :must_have_valid_path
  validate :must_exist_on_disk
  
  def self.list_uncataloged_files
    list = Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.new(filename) }
    list.reject! {|file| Video.exists?(:filename => File.basename(file.path)) }
    list.partition { |file| File.directory?(file) }.flatten!
  end
  
  def before_save
    self.size = File.size(path)
  end
  
  def path
    File.expand_path(File.join(Video::VIDEO_DIR, filename))
  end
  
  def valid_path?
    # filename =~ /^#{Video::VIDEO_DIR}/
    video_path = Pathname.new VIDEO_DIR
    Pathname.new(path).ascend { |path| return true if path == video_path }
    return false
  end
  
  def must_have_valid_path
    errors.add_to_base("The path must point to a valid file") unless valid_path?
  end

  def must_exist_on_disk
    if valid_path?
      errors.add_to_base("The file does not exist on disk") unless File.exists?(path)
    end
  end
end
