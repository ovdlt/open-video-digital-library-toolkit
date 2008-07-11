module VideosHelper
  def file_size(file)
    number_to_human_size(file.stat.size) if File.file?(file)
  end
end
