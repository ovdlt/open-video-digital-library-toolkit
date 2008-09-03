module AssetsHelper

  def file_ext(file)
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    ( ext = File.extname(file.path) ) and ext[1,ext.length].upcase
  end
  
end
