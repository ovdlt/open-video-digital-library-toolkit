namespace :spec do
  namespace :db do
    namespace :fixtures do
      task :load do
        system "rsync -qarv #{RAILS_ROOT}/spec/fixtures/assets/. "+
               "#{RAILS_ROOT}/public/assets/."
        system "rsync -qarv #{RAILS_ROOT}/spec/fixtures/surrogates/. "+
               "#{RAILS_ROOT}/public/surrogates/."
      end
    end
  end
end
