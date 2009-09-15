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
  
  def new_password_notification user, password
    prefix = UsersController.prefix
    setup_email(user)
    @subject    += 'Your new OVDLT password'
    @body[:password] = password
    @body[:url]  = "#{prefix}login?login=#{user.login}"
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
