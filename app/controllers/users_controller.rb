class UsersController < ApplicationController
  include InviteCodeHelper
  before_action :signed_in_user,  except: [:new, :create]
  #before_action :correct_user,    except: [:new, :create]


  def new
    @user = User.new
    render layout: false
  end

  def show
    #@user = User.find(params[:id])
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      if not invite_code_activated? or valid_invite_code?(params[:invite_code]) or Rails.env.test?
        if @user.save
          #flash[:success] = I18n.t('controllers.users.create.success')
          sign_in @user
          @user.build_initial_content
          redirect_to root_url
        else
          render 'new', layout: false
        end
      else
        SignupAttempt.create( invite_code: params[:invite_code], name: params[:user][:name], email: params[:user][:email] )
        render 'no_invite'
      end
    else
      render 'new', layout: false
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(user_params)
      flash[:success] = I18n.t('controllers.users.update.success')
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Guide

  def ok_guide
    guide = current_user.guide
    guide[ params[:guide].to_sym] = true
    current_user.update_attribute( :guide, guide)
    redirect_back
  end

  # Email Confirmation

  def require_email_confirmation
    if current_user.send_email_confirmation!
      flash[:success] = t('controllers.users.require_email_confirmation.success')
    else
      flash[:warning] = t('controllers.users.require_email_confirmation.warning')
    end
    redirect_back
  end

  def confirm_email
    token = params[:token]
    if current_user.confirm_email!(token)
      flash[:success] = t('controllers.users.confirm_email.success')
    else
      flash[:warning] = t('controllers.users.confirm_email.warning')
    end
    redirect_to current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end
end
