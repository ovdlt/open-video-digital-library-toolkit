module ApplicationHelper

  def _file_size(file)
    file = File.new( File.join( Asset::ASSET_DIR, file[8,file.length] ) )
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def uncataloged_files options
    if options[:paged]
      @files_paged ||= Asset.paginate_uncataloged_files(params)
    else
      @files ||= Asset.list_uncataloged_files
    end
  end

  def int_to_duration v
    return nil if v.nil?
    h = v/3600
    m = ( v % 3600 ) / 60
    s = ( v % 3600 ) % 60
    "%02d:%02d:%02d" % [ h, m, s ]
  end

end
