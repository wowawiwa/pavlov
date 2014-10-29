class ListsController < ApplicationController
  before_action :signed_in_user

  def new
    @list = current_user.lists.new( name: params[:list_name] || "")
    @back_url = request.referer
    store_location @back_url
  end

  def create
    @list = current_user.lists.new( list_processed_params)
    if @list.save
      flash[:success] = I18n.t("controllers.lists.create.success")
      redirect_session_or
    else
      render 'new'
    end
  end

  def edit
    @list = current_user.lists.find_by( id_param)
    @back_url = request.referer
    store_location @back_url
  end

  def update
    @list = current_user.lists.find_by( id_param)
    if @list.update_attributes(list_processed_params)
      flash[:success] = I18n.t("controllers.lists.update.success")
      redirect_session_or
    else
      render 'edit'
    end
  end

  def destroy
    if list = current_user.lists.find_by( id_param) and list and list.destroy
      flash[:success] = I18n.t("controllers.lists.destroy.success")
    else
      flash[:warning] = I18n.t("controllers.lists.destroy.warning")
    end
    redirect_back
  end

  private

  def list_params_preprocessing
    # When user choses mail, compute the missing chronos_capacity_ts from the other inputs.
    if params[:list][:review_mode] == "mail"
      params[:list][:chronos_capacity_ts] = { "days" => (params[:list][:review_mail_recurrency] == "7" ? 1.to_s : 7.to_s) }
      params[:list][:chronos_capacity_volume] = 15 if params[:list][:chronos_capacity_volume].blank? # TODO rather display error ?
    end
  end

  def list_processed_params opts={}
    list_params_preprocessing
    params.require(:list).permit(:name, :reverse, :review_mail_recurrency, :review_mode, :chronos_capacity_volume, chronos_capacity_ts: [:days], chronos_success_min_ts: [:days, :hours, :minutes])
  end
end
