class EvaluationsController < ApplicationController
  before_action :signed_in_user

  def new
    if list = decode_list
      now = Time.zone.now

      card_scope = decode_card_scope( list)
      chronos_settings = list.remaining_capacity(now)
      chronos = Program::Chronos.new
      if @card = chronos.select( card_scope, now, chronos_settings)
        @evaluation = Evaluation.new
        @word = @card.evaluable
        @edit_url = edit_card_url(@card)
        @debug[:selector] = chronos.stats
        # as hidden field
        @scope_encoded = encode_card_scope
      end
      @scope_name = list.name
      @correction_url = params[:last_evaluation_id].try{|t| edit_evaluation_url( t)}
    else
      flash[:warning] = I18n.t("controllers.evaluations.new.warning", scope_name: @scope.name)
      redirect_back
    end
  end

  def create
    card = current_user.cards.find(params[:card_id])
    evaluation = card.evaluations.new( evaluation_params)
    redirect_options = {}
    if evaluation.save
      redirect_options.merge!( last_evaluation_id: evaluation.id)
    else
      flash[:warning] = I18n.t("controllers.evaluations.create.warning")
    end
    # scope_hash_with_params_fallback
    redirect_to new_evaluation_url( encode_card_scope.merge( redirect_options))
  end

  def edit
    if @evaluation = current_user.evaluations.find_by( id_param)
      store_location request.referer # the flash could be used instead
      @card = @evaluation.card
      @word = @card.evaluable
      #render 'edit'
    else
      flash[:warning] = I18n.t("controllers.evaluations.edit.warning")
      redirect_back # and return
    end
  end

  def update
    evaluation = current_user.evaluations.find_by( id_param)
    if evaluation and evaluation.update_attributes( evaluation_params)
      flash[:success] = I18n.t("controllers.evaluations.update.success")
    else
      flash[:warning] = I18n.t("controllers.evaluations.update.warning")
    end
    redirect_session_or
  end

private

  def decode_list
    params[:list_name].try{|list_name| current_user.lists.find_by( name: list_name)}
  end

  # Converts parameter given scoping options to a scope object or nil if the options are not correct.
  # A scope object, i.e. an object that minimaly respond to :cards
  def decode_card_scope( list)
    card_scope_opts = params[:reverse].try(&:to_sym)
    list.checkables( card_scope_opts)
  end

  # Generate a scope hash based on the parameters
  def encode_card_scope
    return params.select{|k,v| k.in? %w{list_name reverse}}
  end

  # General purpose

  def evaluation_params
    params.require(:evaluation).permit(:result)
  end
end
