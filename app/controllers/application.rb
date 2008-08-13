# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem

  
  helper :all # include all helpers, all the time
  
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


end
