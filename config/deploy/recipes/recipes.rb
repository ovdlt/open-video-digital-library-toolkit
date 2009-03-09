# Because of themes, etc., Cap's native timestamping isn't going to work anyway ...
# Note that this failure seems benign

# set :normalize_asset_timestamps, false

set :shared_dirs, [ "public/assets", "public/surrogates" ]

after 'deploy:setup', :roles => [ :app, :web ] do

  shared_dirs.each do |dir|
    run "mkdir -p #{shared_path}/#{dir}"
  end
  
  run "mkdir -p #{shared_path}/config/initializers"
  put `erb config/initializers/site_keys.rb.erb`, "#{shared_path}/config/initializers/site_keys.rb.new"
  
  run <<EOS
if [ -e #{shared_path}/config/initializers/site_keys.rb ];
then
 rm #{shared_path}/config/initializers/site_keys.rb.new;
else
 mv #{shared_path}/config/initializers/site_keys.rb.new #{shared_path}/config/initializers/site_keys.rb;
fi
EOS

end

after 'deploy:symlink', :roles => :app do
  sudo "bash -c '(cd #{current_path} && rake gems:install)'"
  shared_dirs.each do |dir|
    run "ln -nfs #{shared_path}/#{dir} #{release_path}/#{dir}"
  end
  run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
  run "rm -f #{release_path}/public/themes/*/stylesheets/cache/*.css"
end

namespace :sass do
  desc 'Updates the stylesheets generated by SASS'
  task :update, :roles => :app do
    invoke_command "cd #{latest_release}; RAILS_ENV=#{rails_env} rake sass:update"
  end

  # Generate all the stylesheets manually (from their Sass templates) before each restart.
  before 'deploy:restart', 'sass:update'
end
