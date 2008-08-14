class UsersController < ApplicationController

  before_filter :admin_required,
                :only => [:suspend, :unsuspend, :destroy, :purge]

  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_to login_path
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to login_path
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_to login_path
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so,
  # that they supply their old password along with a new one to update it, etc.

  def show
    @user = User.find params[:id]
    if @user != current_user
      render :file => "#{RAILS_ROOT}/public/404.html",  
             :status => 404
      return
    end
  end

  def change_password

    @user = User.find params[:id]

    if @user != current_user
      render :file => "#{RAILS_ROOT}/public/404.html",  
             :status => 404
      return
    end

    new_password = params[:new_password]
    confirm_password = params[:confirm_password]

    if new_password != confirm_password
      flash.now[:error] = "password and password confirmation not the same"
      render :action => :show
      return
    end

    if new_password.blank?
      flash.now[:error] = "new password cannot be blank"
      render :action => :show
      return
    end

    if !@user.authenticated? params[:old_password]
      flash.now[:error] = "password incorrect"
      render :action => :show
      return
    end

    @user.password = new_password
    @user.password_confirmation = confirm_password
    @user.save!

    flash.now[:notice] = "password changed"
    render :action => :show

  end


  def reset_password

    email = params["email"]
    user = User.find_by_email email

    if !user
      flash.now[:error] = "Can't find that email; sorry"
      @email = email
      render :action => "forgot_password"
    elsif user.state == "pending"
      new_password = random_password
      user.password = new_password
      user.password_confirmation = new_password
      user.save!
      UserMailer.deliver_signup_notification(user)
      flash[:notice] = "You have not yet activated your account.  We're sending you another email with an activation link and a new password."
      redirect_to login_path
    else
      new_password = random_password
      user.password = new_password
      user.password_confirmation = new_password
      user.save!
      UserMailer.deliver_new_password_notification(user,new_password)
      flash.now[:notice] = "A new password has been sent to your email account"
      render :template => "sessions/new"
    end

  end

  protected

  def find_user
    @user = User.find(params[:id])
  end

  private

  def admin_required
    if !(current_user and current_user.is_admin)
      render :file => "#{RAILS_ROOT}/public/404.html",  
      :status => 404
      return
    end
  end

  def random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end

end
