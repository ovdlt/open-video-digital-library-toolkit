#!/usr/bin/env ruby

require 'fileutils'

if !ARGV[0]
  print "usage: ruby init.rb <directory_name>\n"
  exit 0
end

include FileUtils

mkdir_p ARGV[0]
system "tar Cxvfpz #{ARGV[0]} ~/ovdlt/ovdlt.tgz"
chdir ARGV[0]
system "mv ovdlt/{*,.[a-zA-Z]*} ."
rmdir "ovdlt"
