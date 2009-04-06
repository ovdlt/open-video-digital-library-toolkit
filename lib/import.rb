def import basename_or_csv, map_file = nil

  csv = nil

  begin
    csv = open( basename_or_csv, "r" )
  rescue Errno::ENOENT
    begin
      csv = open( "#{basename_or_csv}.csv", "r" )
    rescue Errno::ENOENT
      begin
        csv = open( "#{basename_or_csv}.CSV", "r" )
      rescue Errno::ENOENT; end
    end
  end

  if !csv
    $stderr.puts "cannot open CSV for #{basename_or_csv}"
    exit 1
  end

  map = nil

  if map_file
    begin
      map = open map_file, "r"
    rescue Errno::ENOENT; end
  else
    begin
      map_file = basename_or_csv
      map_file.sub( /\.[^\.]$/, "" )
      map = open( "#{map_file}.map", "r" )
    rescue Errno::ENOENT; end
  end

  if !map
    $stderr.puts "cannot open map file for #{basename_or_csv}"
    exit 1
  end

end
