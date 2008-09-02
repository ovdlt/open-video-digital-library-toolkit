module AssetsHelper

  def file_size file
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def file_ext(file)
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    File.extname(file.path)
  end
  
  def file_base(file)
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    File.basename(file.path)
  end
  
  def link_to_add_asset(video,file)
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    link_to "add",
            new_video_asset_path( video,
                                  :filename => File.basename(file.path) )
    
  end

end
