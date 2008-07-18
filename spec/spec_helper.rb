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
  
  config.after(:suite) { delete_temp_videos }
end

def create_temp_video(filename, size=100)
  path = File.join(VIDEO_DIR, filename)
  File.delete(path) if File.exists?(path)
  new_file = File.open(path, "w") { |f| f << "j"*size }
  return File.new(path)
end

def delete_temp_videos
  Dir.glob("#{VIDEO_DIR}/*").map { |filename| File.delete(filename) }
end