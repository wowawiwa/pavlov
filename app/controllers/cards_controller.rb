class CardsController < ApplicationController
  before_action :signed_in_user

  # TODO Patch model to be able to build a polymorphic 1 to 1 association

  def new
    @card = current_user.build_card( Word.new, name: params[:list_name] || list_last_name)
    @back_url = flash[:back_url] || request.referer
  end

  def create
    @card = current_user.build_card( Word.new( word_params), list_name_param)
    @back_url = params[:back_url]
    if @card.save
      flash[:success] = I18n.t('controllers.cards.create.success')
      flash[:back_url] = @back_url
      redirect_to new_card_url
    else
      render 'new'
    end
  end

  # TODO Handle if not found
  def edit
    @card = current_user.cards.find_by( id_param)
    @back_url = request.referer
  end

  def update
    @card = current_user.build_card( word_params, list_name_param, id_param)
    @back_url = params[:back_url]
    if @card.save
      flash[:success] = I18n.t('controllers.cards.update.success')
      redirect_to @back_url
    else
      render 'edit'
    end
  end

  def destroy
    if card = current_user.cards.find_by( id_param) and card and card.destroy
      flash[:success] = I18n.t("controllers.cards.destroy.success")
    else
      flash[:warning] = I18n.t("controllers.cards.destroy.warning")
    end
    redirect_back
  end

  def index
    if not @list = current_user.lists.find_by( name: params[:list_name])
      flash[:warning] = I18n.t('controllers.cards.index.warning')
      redirect_back
    end
  end

  def new_batch
    if not @list = current_user.lists.find_by( name: params[:list_name])
      flash[:warning] = I18n.t('controllers.cards.new_batch.warning')
      redirect_back
    end
  end

  def import
    @list = current_user.lists.find_or_initialize_by( name: params[:list_name])
    reverse = !!params[:reverse] || false
    if params[:file] and @list and @list.valid?
      count_success, count_fail = Pavlov.import_words( params[:file]) do |content, tip|
        content, tip = (tip || "?"), content if reverse
        current_user.build_card( Word.new( content: content, tip: tip), @list)
      end
      # TODO move in Card#import ?
      if count_fail == 0
        flash[:success] = I18n.t("controllers.cards.import.success", 
                                 count: Card.model_name.human(count: count_success))
      else
        flash[:info] = I18n.t("controllers.cards.import.info", 
                              count_success: Card.model_name.human(count: count_success), 
                              count_fail: Card.model_name.human(count: count_fail))
      end
      redirect_to new_card_url
    else
      flash.now[:warning] = I18n.t("controllers.cards.import.warning")
      render 'new_batch'
    end
  end

  # TODO move in index action ?
  def export
    # TODO move in Card#to_csv ?
    data = CSV.generate col_sep: "|" do |csv|
      csv << [Word.human_attribute_name(:content), Word.human_attribute_name(:tip), List.model_name.human]
      current_user.lists.all.each do |l|
        l.words.all.each do |w|
          csv << [w.content, w.tip, w.card.list.name].map{|s| s.gsub(/[^[:print:]]/i, '')}
        end
      end
    end

    respond_to do |format|
      #format.html
      format.csv do send_data data, 
                              type: 'text/csv; charset=utf-8; header=present', 
                              filename: Card.model_name.human.pluralize + "_" + I18n.t("application.name") + ".csv"
      end
    end
  end

private

  def helpers
    ActionController::Base.helpers
  end

  def list_last_name
    current_user.cards.desc.first.try{|c| c.list.name} || ""
  end

  def word_params opts={}
    params.require(:word).permit(:content, :tip)
  end

  # If the card has an evaluable already, it is updated with the evaluable argument. 
  # Otherwise, it is assigned with the evaluable argument.
  #def build_card( evaluable, list={}, card={})
  #  new_card       = card.kind_of?(Hash) ? current_user.cards.find_or_initialize_by( card) : card
  #  new_card.list  = list.kind_of?(Hash) ? current_user.lists.find_or_initialize_by( list) : list
  #  new_card.evaluable ? new_card.evaluable.assign_attributes( evaluable) : new_card.evaluable = evaluable
  #  new_card
  #end
end
