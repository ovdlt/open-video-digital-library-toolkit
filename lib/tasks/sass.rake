namespace :sass do
  desc 'Updates stylesheets if necessary from their Sass templates.'
  task :update => :environment do

    Library.available_themes.each do |theme|
      Sass::Plugin.options.merge!( { :template_location => "#{RAILS_ROOT}/public/themes/#{theme}/stylesheets/sass",
                                      :css_location => "#{RAILS_ROOT}/public/themes/#{theme}/stylesheets",
                                     } )
      Sass::Plugin.update_stylesheets
    end

  end

end
