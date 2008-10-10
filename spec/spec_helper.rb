ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + '/factories')
require File.expand_path(File.dirname(__FILE__) + '/video_helper')
require File.expand_path(File.dirname(__FILE__) + '/asset_helper')
require 'spec'
require 'spec/rails'

include AuthenticatedTestHelper
include AuthenticatedSystem

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  config.global_fixtures = :all
  
  config.after(:suite) { delete_temp_assets }
end

include AuthenticatedSystem

def login_as_mock_user
  self.current_user = mock_user
end

def login_as_user
  self.current_user = User.find( :all ).detect do
    |u| !u.has_role?( [:admin, :cataloger] )
  end
end

def login_as_other_user
  
  self.current_user = User.find( :all ).detect do
    |u| !u.has_role?( [:admin, :cataloger] ) and
         u.id != current_user.id
  end
end

def login_as_admin
  self.current_user = User.find( :all ).detect { |u| u.has_role? "admin" }
end

def login_as_cataloger
  self.current_user = User.find( :all ).detect do
    |u| u.has_role? "cataloger" and !u.has_role? "admin"
  end
end

def login_as_collections
  self.current_user = User.find Library.collections_user_id
end

def logout
  self.current_user = nil
end

