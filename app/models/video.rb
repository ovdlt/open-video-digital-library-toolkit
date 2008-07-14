class Video < ActiveRecord::Base
  VIDEO_DIR = "#{RAILS_ROOT}/videos"
  
  def filename=(fname)
    self[:filename] = File.expand_path(File.join(Video::VIDEO_DIR, fname))
  end
  
  def self.list_videos
    list = Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.new(filename) }
    list.partition { |file| File.directory?(file) }.flatten
  end
  
  def basename
    File.basename filename
  end
  
  def valid_path?
    # filename =~ /^#{Video::VIDEO_DIR}/
    video_path = Pathname.new VIDEO_DIR
    Pathname.new(filename).ascend { |path| return true if path == video_path }
    return false
  end
end
