class Video < ActiveRecord::Base
  VIDEO_DIR = "#{File.dirname(__FILE__)}/../../videos"
  
  def self.list_videos
    list = Dir.glob("#{VIDEO_DIR}/*").inject([]) do |acc, file|
      acc << { :filename => File.basename(file, File.extname(file)),
               :size     => File.size(file),
               :type     => File.extname(file) 
             }
    end
    list.partition{ |file| file[:type].blank? }.flatten
  end
end
