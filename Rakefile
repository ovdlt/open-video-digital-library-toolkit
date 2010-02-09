# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
Rake::Task[:default].prerequisites.clear
task :default => :spec

# //////////////////////
# Rake task for clearing asset cache
# //////////////////////////////////
 
namespace :tmp do
  namespace :assets do
    desc "Clears javascripts/cache and stylesheets/cache"
    task :clear => :environment do      
      FileUtils.rm(Dir['public/javascripts/cache/[^.]*'])
      FileUtils.rm(Dir['public/stylesheets/cached*'])
    end
  end
end

task :release do
  rm_rf "pkg"
  mkdir_p "pkg/ovdlt"
  system "cp -r . pkg/ovdlt"

  rm_f "pkg/ovdlt/config/initializers/site_keys.rb"
  rm_f "pkg/ovdlt/config/database.yml"
  rm_f "pkg/ovdlt/coverage/*"
  rm_rf "pkg/ovdlt/pkg"
  cmd = "rm -rf pkg/ovdlt/tmp/* pkg/ovdlt/tmp/.* pkg/ovdlt/public/surrogates pkg/ovdlt/public/assets"
  puts cmd
  system cmd
  system 'find pkg/ovdlt/log -name \\*.log| xargs rm -f'
  system 'find vendor -name \\*.o -o -name \\*.bundle -o -name \\*.so | xargs rm -f'
  system 'find vendor -name Makefile | fgrep /ext/ | xargs rm -f'

  rm_f "pkg/ovdlt/ovdlt.tgz"
  mkdir_p "pkg/ovdlt/public/surrogates pkg/ovdlt/public/assets"
  system "find pkg -name .git | xargs rm -rf"
  system "(cd pkg; tar cf - ovdlt | gzip -9 > ../ovdlt.tgz)"
end
