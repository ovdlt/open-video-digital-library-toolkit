#!/usr/bin/env ruby

require 'yaml'

File.open( "openvideo_source_10-21-2008_vid-Table 1.map" ) do |f|
  yml = f.read
  hash = { "open_video" => { "name" => "Open Video Test Map",
                             "yml" => yml } }

  File.open( "fixture.yml", "w" ) do |w|
    YAML::dump hash, w
  end
end
