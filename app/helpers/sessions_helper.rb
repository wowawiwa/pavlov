module SessionsHelper

  # Sign in/out

  # return the cookie matching user (if any) or nil (lazy/memoize)
  def current_user
    @current_user ||= User.find_by( remember_token: User.hash( cookies[:remember_token]))
  end

  def current_user?(user)
    user.id == current_user.id
  end

  def admin?
    current_user and ((current_user.email == ENV['ADMIN_EMAIL']) or Rails.env.development?)
  end

  # generate and save an encrypted key to the parameter-given User
  # and entrust the client with it
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.hash(remember_token))
    @current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  # invalidate existing key (also in cache) - corresponding to the signed-in user preventing 
  def sign_out
    # delete saved key
    current_user.update_attribute(:remember_token,
                                  User.hash( User.new_remember_token)) # if signed_in?
    # delete cache
    @current_user = nil
    # delete key by the user (optional)
    cookies.delete(:remember_token)
  end

  # Filters

  def signed_in_user
    unless signed_in?
      store_location
      flash[:info] = I18n.t('helpers.sessions.signin_redirection')
      redirect_to signin_url
    end
  end
end
