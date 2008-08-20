module VideosHelper

  def file_size(file)
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def link_to_add_video(file)
    unless Asset.exists?(:uri => "file:///" + File.basename(file.path)) ||
        file.stat.directory?
      link_to("add", new_video_path(:filename => File.basename(file.path)))
    end
  end

  def page_format
    ( params[:list_format] || :list ).to_sym
  end

  def details_format
    ( params[:details_format] || :details ).to_sym
  end

  def current format
    if format == page_format
      {:class => "current"}
    else
      {}
    end
  end

  def link_to_format format
    s = "#{format.to_s.capitalize} View"
    if format == page_format
      "#{format.to_s.capitalize} View"
    else
      link_to s, @path.call( format == :list ? {} : { :list_format => format })
    end
  end

  def link_to_details details
    s = "#{details.to_s.capitalize}"
    if details == details_format
      "#{details.to_s.capitalize}"
    else
      link_to s, @path.call( details == :details ?
                                              {} :
                                              { :details_format => details })
    end
  end

end
