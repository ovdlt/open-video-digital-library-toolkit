ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

include AuthenticatedTestHelper
include AuthenticatedSystem

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  config.global_fixtures = :all
  
  config.after(:all) { delete_temp_videos }
end

def create_temp_video(filename, size=100)
  @files ||= []
  unless @files.any? {|file| file.stat.basename == filename }
    file = File.open(File.join(Video::VIDEO_DIR, filename), "w") { |f| f << "j"*size }
    @files << file
  end
  file
end

def delete_temp_videos
  @files.each { |file| File.delete(file.path) } if @files
  @files = []
end