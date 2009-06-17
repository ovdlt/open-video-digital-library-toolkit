namespace :cached_assets do
  desc "Regenerate cached files"
  task :regenerate => :environment do
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::AssetTagHelper

    stylesheet_link_tag :all, :cache => "cached"
    javascript_include_tag :all, :cache => "cache/all"
  end
end
