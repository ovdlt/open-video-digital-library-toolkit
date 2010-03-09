#!/usr/bin/env ruby

require 'fileutils'

tarfile = ARGV.shift
dir = ARGV.shift
db_user = ARGV.shift
db_pw = ARGV.shift

if !tarfile || !dir
  print "usage: ruby init.rb <tarfile> <directory_name> <db_user> <db_user_password>\n"
  exit 0
end

include FileUtils

mkdir_p dir
system "cat #{tarfile} | tar Cxfpz #{dir} -"
chdir dir
system "mv ovdlt/{*,.[a-zA-Z]*} ."
rmdir "ovdlt"
system "sed -e s/ovdlt/#{dir}/g -e s/-development//g -e s/-test//g -e s/-production//g -e s/db_user/#{db_user}/ -e s/db_password/#{db_pw}/ config/database.yml.sample > config/database.yml"
text = (1..16).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
system "test -e config/initializers/site_keys.rb || sed -e 's/CHANGE THIS!!!!!!!!/#{text}/' config/initializers/site_keys.rb.example > config/initializers/site_keys.rb"

cmd = "grep relative_url_root config/environment.rb || perl -pi -e 's/:user_observer/:user_observer\\n\\nconfig.action_controller.relative_url_root = \"\\/#{dir}\"/' config/environment.rb"
puts cmd
system cmd

cmd = "grep :sendmail config/environment.rb || echo 'ActionMailer::Base.delivery_method = :sendmail' >> config/environment.rb"
puts cmd
system cmd

cmd = "grep :location config/environment.rb || echo 'ActionMailer::Base.sendmail_settings[:location] = %(/usr/bin/sendmail)' >> config/environment.rb"
puts cmd
system cmd

system "rake gems:build"
ENV["RAILS_ENV"] = "production"
system "rake db:create"
system "rake db:migrate"

cp_r "spec/fixtures/assets", "public"
cp_r "spec/fixtures/surrogates", "public"
system "rake spec:db:fixtures:load"

# system "rake db:populate"
