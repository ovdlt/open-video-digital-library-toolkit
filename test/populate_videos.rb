#!/usr/bin/env ruby
unless $0 =~ /runner/
  system("#{File.join(File.dirname(__FILE__),"..","script")}/runner", __FILE__, *ARGV )
  exit 0
end

require File.expand_path(File.join(File.dirname($0),"..","spec","factories"))
require File.expand_path(File.join(File.dirname($0),"..","spec","video_helper"))

types = DescriptorType.find( :all ).to_a
values = []
types.each do |type|
  values[type.id] = type.descriptors.to_a
end

# DANGEROUS!

(Video.find :all ).each { |v| v.destroy }

if ARGV[0] != "FORCE"
  puts "must give FORCE as first argument since this script wipes all the videos"
  exit -1  
end

ARGV.shift

years = (1850..2008).to_a

( ARGV[0] || 64 ).to_i.times do
  v = Factory(:video)
  v.year = years[rand(years.size)]
  types.each do |type|
    v.descriptors << values[type.id][ rand(values[type.id].size) ]
  end
  v.save!

  puts v.to_yaml
  
end
