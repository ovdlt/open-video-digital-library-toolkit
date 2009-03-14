# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include RoleRequirementSystem
  
  # helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3fa67d7da1a49d7d8b2883dc9789ea36'
  
  filter_parameter_logging :password

  include ExceptionNotifiable

  # This code traps 404s as well as 500s
  def rescue_action_in_public(exception)
    case exception
    when *self.class.exceptions_to_treat_as_404
      render_404
      deliverer = self.class.exception_data
      data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
             end
      ExceptionNotifier.deliver_exception_notification( exception,
                                                          self,
                                                          request, data)

    else          
      render_500
      deliverer = self.class.exception_data
      data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
             end
      ExceptionNotifier.deliver_exception_notification( exception,
                                                          self,
                                                          request,
                                                          data )
    end
  end

  protected

  before_filter :load_library
  
  def load_library

    library = @library = Library.find(:first)
    theme = library.theme

    # this is sleezy ... may break with new rails ...

    ActionView::Helpers::AssetTagHelper.module_eval do
      remove_const(:STYLESHEETS_DIR) if const_defined? :STYLESHEETS_DIR
      const_set :STYLESHEETS_DIR,
      "#{ActionView::Helpers::AssetTagHelper::ASSETS_DIR}/" \
      "themes/#{theme}/stylesheets"
    end

    ActionView::Helpers::AssetTagHelper::StylesheetAsset.module_eval do
      remove_const(:DIRECTORY) if const_defined? :DIRECTORY
      const_set :DIRECTORY, "themes/#{theme}/stylesheets".freeze
    end

    ActionView::Helpers::AssetTagHelper::ImageAsset.module_eval do
      remove_const(:DIRECTORY) if const_defined? :DIRECTORY
      const_set :DIRECTORY, "themes/#{theme}/images".freeze
    end

    Sass::Plugin.options =
      { :template_location => "./public/themes/#{theme}/stylesheets/sass",
        :css_location => "./public/themes/#{theme}/stylesheets",
    }

  end

  # the prefix is used when generating emails so that we don't have to
  # hardcode the host and port

  @@prefix = nil

  before_filter :set_prefix

  def set_prefix
    @@prefix = "http://#{request.host_with_port}/"
  end

  def self.prefix
    @@prefix
  end

  def render_nothing
    render :nothing => true, :status => interpret_status(200)
  end
  
  def render_missing
    render :nothing => true, :status => interpret_status(404)
  end
  
  def render_bad_request
    render :nothing => true, :status => interpret_status(400)
  end

  def duration_to_int value, object, key
    return nil if value.blank?
    if m = value.match( /^\s*(\d\d):(\d\d):(\d\d)\s*$/ )
      return ((m[1].to_i*60)+m[2].to_i)*60+m[3].to_i
    else
      object.errors.add key, "#{value} is not a valid duration"
      return nil
    end
  end

  def login
    current_user or redirect_to login_path
  end

  def check_video_viz video
    video.public? or ( current_user and current_user.has_role?([:admin,:cataloger]) )
  end

  def public_only?
    !current_user or !current_user.has_role?([:admin,:cataloger])
  end

  def viz_condition
    ( current_user and
      current_user.has_role?([:admin,:cataloger]) ) ? {} : { :public => true }
  end

  def videos_method
    public_only? ? :public_videos : :all_videos
  end

  def video_ids_method
    public_only? ? :public_videos : :all_videos
  end

end
