require 'deprec'
  
set :database_yml_in_scm, false


set :application, "ovdlt"
set :domain, "ovdlt.smparkes.net"
set :repository, "git://github.com/ovdlt/open-video-digital-library-toolkit.git"
# set :gems_for_project, %w(dr_nic_magic_models swiftiply) # list of gems to be installed
set :gems_for_project, %w(haml thoughtbot-factory_girl)

# Update these if you're not running everything on one host.
role :app, domain
role :web, domain
role :db,  domain, :primary => true

# If you aren't deploying to /var/www/apps/#{application} on the target
# servers (which is the deprec default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git

namespace :deploy do

  task :restart, :roles => :app, :except => { :no_release => true } do
    top.deprec.mongrel.restart
  end

  db_params = {
    "adapter"=>"mysql",
    "database"=>"#{application}_#{rails_env}",
    "username"=>"root",
    "password"=>"",
    "host"=>"localhost",
    "socket"=>""
  }

  db_params.each do |param, default_val|
    set "db_#{param}".to_sym,
    lambda { Capistrano::CLI.ui.ask "Enter database #{param}" do |q| q.default=default_val end}
  end

  task :my_generate_database_yml, :roles => :app do
    database_configuration = "#{rails_env}:\n"
    db_params.each do |param, default_val|
      val=self.send("db_#{param}")
      database_configuration<<"  #{param}: #{val}\n"
    end
    run "mkdir -p #{deploy_to}/#{shared_dir}/config"
    put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml"
  end

  after 'deploy:symlink', :roles => :app do
    run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
    run "chgrp -R #{mongrel_group} #{release_path}/public/stylesheets"
  end

end

SRC_PACKAGES[:ruby] = {
  :filename => 'ruby-1.8.6-p287.tar.gz',   
  :md5sum => "f6cd51001534ced5375339707a757556  ruby-1.8.6-p287.tar.gz", 
  :dir => 'ruby-1.8.6-p287',  
  :url => "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p287.tar.gz",
  :unpack => "tar zxf ruby-1.8.6-p287.tar.gz;",
  :configure => %w(
    ./configure
    --with-readline-dir=/usr/local
    ;
    ).reject{|arg| arg.match '#'}.join(' '),
  :make => 'make;',
  :install => 'make install;'
}
  
SRC_PACKAGES[:rubygems] = {
  :filename => 'rubygems-1.2.0.tgz',   
  :md5sum => "b77a4234360735174d1692e6fc598402  rubygems-1.2.0.tgz", 
  :dir => 'rubygems-1.2.0',  
  :url => "http://rubyforge.org/frs/download.php/38646/rubygems-1.2.0.tgz",
  :unpack => "tar zxf rubygems-1.2.0.tgz;",
  :install => 'ruby setup.rb;'
}
      
