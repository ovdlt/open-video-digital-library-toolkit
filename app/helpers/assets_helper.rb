module AssetsHelper

  def file_size(file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def file_ext(file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    File.extname(file.path)
  end
  
  def file_base(file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    File.basename(file.path)
  end
  
  def link_to_add_asset(video,file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    link_to "add",
            new_video_asset_path( video,
                                  :filename => File.basename(file.path) )
    
  end

end
