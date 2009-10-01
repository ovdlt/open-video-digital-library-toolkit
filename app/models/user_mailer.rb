class UserMailer < ActionMailer::Base

  def signup_notification(user)
    prefix = UsersController.prefix
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "#{prefix}activate/#{user.activation_code}"
  end
  
  def activation(user)
    prefix = UsersController.prefix
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{prefix}"
  end
  
  def forgot_password user
    prefix = UsersController.prefix
    setup_email(user)
    @subject    += 'Password reset request'
    @body[:url]  = "#{prefix}reset_password/#{user.password_reset_code}"
  end

  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    prefix = UsersController.prefix
    @from        = Library.email
    @subject     = "[#{prefix}] "
    @sent_on     = Time.now
    @body[:user] = user
  end

end
