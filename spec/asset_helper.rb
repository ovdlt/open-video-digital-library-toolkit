def create_temp_asset(filename, size=100)
  path = File.join(ASSET_DIR, filename)
  File.delete(path) if File.exists?(path)
  new_file = File.open(path, "w") { |f| f << "j"*size }
  return File.new(path)
end

def delete_temp_assets
  Dir.glob("#{ASSET_DIR}/*").map { |filename| File.delete(filename) }
end
