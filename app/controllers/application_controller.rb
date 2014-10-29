class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_filter do
    clear_location if params[:clear_location]
    @debug = {}
  end

  #before_filter :set_locale # TODO

private

  # Redirection

  def redirect_session_or(fall_back=nil)
    redirect_to(session[:return_to] || fall_back || root_url)
    session.delete(:return_to)
  end

  def location
    session[:return_to]
  end

  def store_location location=nil
    session[:return_to] = location || (request.url if request.get?)
  end

  def clear_location
    session.delete(:return_to)
  end

  def redirect_back(default=nil)
    redirect_to(:back)
  rescue ActionController::RedirectBackError
    redirect_to default || root_path
  end

  # Params filters

  # TODO remove and use the lists id
  def list_name_param opts={}
    params.require(:list).permit(:name)
  end

  def id_param
    params.permit(:id)
  end

  # Locale

  def set_locale
    I18n.locale = current_user.language if logged_in?
  end
end
