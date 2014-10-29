class SessionsController < ApplicationController
  include SessionsHelper

  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in user
      redirect_session_or
    else
      flash.now[:warning] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  # Password Reset

  def new_password_reset_request
  end

  def create_password_reset_request
    user = User.where(email: params[:email]).first
    if user.blank? or user.send_password_reset!
      flash[:success] = t('controllers.sessions.create_password_reset_request.success')
    else
      flash[:warning] = t('controllers.sessions.create_password_reset_request.warning')
    end
    redirect_to signin_url
  end

  def reset_password
    @user = User.where(password_reset_token: params[:token]).first
    @token = params[:token]
    redirect_to(root_path) unless @user
  end

  def update_password
    @user = User.where(password_reset_token: params[:token]).first
    @token = params[:token]
    if @user.reset_password!(@token, password_param)
      flash[:success] = I18n.t('controllers.users.update.success')
      redirect_to signin_url
    else
      render 'reset_password'
    end
  end

  private

  def password_param
    params.require(:user).permit(:password, :password_confirmation)
  end

end
