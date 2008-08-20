module AssetsHelper

  def file_size(file)
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def link_to_add_asset(file)
    unless Asset.exists?(:uri => "file:///" + File.basename(file.path)) ||
           file.stat.directory?
      link_to("add", new_video_path(:filename => File.basename(file.path)))
    end
  end

end
