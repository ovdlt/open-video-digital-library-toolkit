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
  values[type.id] = type.descriptor_values.to_a
end

( ARGV[0] || 64 ).to_i.times do
  Factory(:video)
end
