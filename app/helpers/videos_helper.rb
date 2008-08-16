module VideosHelper

  def file_size(file)
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def link_to_add_video(file)
    unless Video.exists?(:filename => File.basename(file.path)) ||
        file.stat.directory?
      link_to("add", new_video_path(:filename => File.basename(file.path)))
    end
  end

  def page_format
    ( params[:list_format] || :list ).to_sym
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
      o = { :list_format => format }
      link_to s, @path.call( format == :list ? {} : { :list_format => format })
    end
  end

end
