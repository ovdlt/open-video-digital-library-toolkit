def create_temp_video(filename, size=100)
  path = File.join(VIDEO_DIR, filename)
  File.delete(path) if File.exists?(path)
  new_file = File.open(path, "w") { |f| f << "j"*size }
  return File.new(path)
end

def delete_temp_videos
  Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.delete(filename) }
end
