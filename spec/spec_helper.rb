ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + '/factories')
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
  
  unless @files.any? {|file| File.basename(file.path) == filename }
    new_file = File.open(File.join(Video::VIDEO_DIR, filename), "w") { |f| f << "j"*size }
    file = File.new(new_file.path) # because new_file is closed and we can't use it
    @files << file
    return file
  end
end

def delete_temp_videos
  @files.each { |file| File.delete(file.path) } if @files
  @files = []
end