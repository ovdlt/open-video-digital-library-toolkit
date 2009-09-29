# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # config.gem "mysql", :version => "2.7" # may require "gem install mysql -- --with-mysql-config"

  config.gem "abstract", :version => "1.0.0" # needed by erubis
  config.gem "erubis", :version => "2.6.5"
  config.gem "fastercsv", :version => "1.5.0"
  config.gem "haml", :version => "2.2.4"
  config.gem "faker", :version => "0.3.1"
  config.gem "RedCloth", :version => "4.2.2"
  config.gem "thoughtbot-factory_girl",
             :version => "1.2.2",
             :lib => "factory_girl",
             :source => "http://gems.github.com"
  config.gem "mislav-will_paginate",
             :version => "2.3.11",
             :lib => "will_paginate",
             :source => "http://gems.github.com"

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_open-video-digital-library-toolkit_session',
    :secret      => '80bbbfa5c844d6e7a69650535b9385f01f6fd76a953dbff24929d9b5908818ef87c15325593733ba7dc1405f65364af9f4ddc5d71d5160e63edd92f29f015a5b'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql
  # NB: required because we use MySQL MyISAM tables and fulltext indexes
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer

end

ExceptionNotifier.exception_recipients = %w(smparkes@smparkes.net)
ExceptionNotifier.sender_address = %("OVDLT Error" <ovdlt@ovdlt.org>)
ExceptionNotifier.email_prefix = "[OVDLT] "

ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery-1.3.2"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery.cookie"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "ui.core"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "ui.accordion"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery.autocomplete"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery.pagination"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery.livequery"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "jquery.carousel.pack"
ActionView::Helpers::AssetTagHelper.
  register_javascript_include_default "facebox"

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "fieldWithErrors"
  if html_tag =~ /<(input|textarea|select)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  html_tag
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
"<span class=\"fieldWithErrors\">#{html_tag}</span>" }

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'criterion', 'criteria'
end

# ActionView::Base.default_form_builder = OvdltFormBuilder
