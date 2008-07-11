class Video < ActiveRecord::Base
  VIDEO_DIR = "#{RAILS_ROOT}/videos"
  
  def self.list_videos
    list = Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.new(filename) }
    list.partition { |file| File.directory?(file) }.flatten
  end
  
  def path
    File.join(VIDEO_DIR, self.filename)
  end
end
