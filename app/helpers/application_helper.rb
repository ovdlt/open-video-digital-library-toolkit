module ApplicationHelper

  def tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def div_for field
    render :partial => "/shared/div", :object => field
  end

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
  
  def sq_path sq
    if sq.descriptor
      if !sq.query_string.blank?
        descriptor_videos_path( sq.descriptor, :query => sq.query_string )
      else
        descriptor_videos_path( sq.descriptor )
      end
    else
      if !sq.query_string.blank?
        videos_path( :query => sq.query_string )
      else
        videos_path
      end
    end
  end

  def browse_descriptors_and_types video
    descriptors = video.descriptors
    types = ( descriptors.map { |d| d.descriptor_type } ).uniq
    types = DescriptorType.browse.select { |dt| types.include? dt }
    types.map { |t| [ t, descriptors.select { |d| d.descriptor_type == t } ] }
  end

  def int_to_duration v
    return nil if v.nil?
    h = v/3600
    m = ( v % 3600 ) / 60
    s = ( v % 3600 ) % 60
    "%02d:%02d:%02d" % [ h, m, s ]
  end

end
