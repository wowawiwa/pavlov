class List < ActiveRecord::Base
  include SharedMethods
  include DurationAttrs
  
  belongs_to :user
  validates_presence_of :user
  has_many :cards, dependent: :destroy
  has_many :evaluations, through: :cards
  has_many :words, through: :cards, source: :evaluable, source_type: Word
  
  scope :display_order, ->{ order( "#{table_name}.name ASC")}

  before_validation{ strip_whitespaces :name}
  validates :name, presence: true, length: { maximum: APP_SETTINGS[:list_name_max_length]}
  validates_uniqueness_of :name, :scope => :user_id
  
  # Content specific
  
  before_validation :set_default_reverse
  validates :reverse, :inclusion => {:in => [true, false]}

  # Mail 
  #before_validation :mail_params_consistency

  def checkables( reverse_flag=nil)
    case reverse_flag
    when :with then cards
    when :without then regulars
    when :only then reverses
    when nil then reverse ? cards : regulars
    else raise("Unknown flag!")
    end
  end

  def indexables
    cards.where( "cards.evaluable_type" => "Word")
  end

  def scope_report
    { total: indexables.count, reverse: reverse}
  end

  include Program::Chronos::ScopeHook

  def self.build_id_hash(list_scope)
    list_scope.each_with_object({}){|list, hash| hash[list.id] = yield(list)}
    # REM alternative ways:
    #list_scope.inject({}){ |agg, list| agg.merge!( list.id => yield(list) )}
    #card_scope_enum.each_with_object({}){|card_scope, h| h[ card_scope.id] = { total: card_scope.checkables.count}}
    #{}.tap{|h| card_scope_enum.each{|card_scope| h[ card_scope.id] = { total: card_scope.cards.count}}}
  end

  # Review Mail TODO move in Chronos 
  
  # Virtual attributes
  def review_mode
    if chronos_capacity_volume == 0
      "paused"
    elsif review_mail_recurrency
      "mail"
    else
      "no_mail"
    end
  end

  def review_mode= review_mode
    if review_mode != "mail" 
      self.review_mail_recurrency = nil 
    end
  end

  def self.review_mail_recurrencies_opts
    (Array(1..6) << 0).map{|day_id| [I18n.t(:"date.day_names")[day_id], day_id]}.unshift(["Day", 7])
  end

  def review_mail_reccurency_str(mode=nil)
    str = List.review_mail_recurrencies_opts.select{|opt| opt[1] == review_mail_recurrency}.first.first if review_mail_recurrency
    if mode == :abr and review_mail_recurrency != 7
      str
    else
      str.downcase
    end
  end

  def self.send_review_mails
    now = Time.zone.now
    List.joins(:user)
        .where( "users.email_confirmed = ?", true)
        .where( "review_mail_recurrency = ? OR review_mail_recurrency = 7", Time.zone.now.wday).each do |list|
      cards = Program::Chronos.new.select( list.checkables, now, list.remaining_capacity(now), :all_at_once)
      if cards.present?
        UserMailer.review_mail(list.user.email, list.user.name, list, cards).deliver
      end
    end
  end

  # / Move in Chronos

  private

  def regulars
    indexables
  end

  def reverses
    cards.where( "cards.evaluable_type" => "WordReverse")
  end

  def set_default_reverse
    self.reverse = false if self.reverse.nil?
    true # REM otherwise, the list is not considered valid until error is called
  end

  #def mail_params_consistency
  #  if review_mode == "mail"  
  #    if not chronos_capacity_volume
  #      self.errors.add :chronos_capacity_volume, "Blah"
  #    end
  #  end
  #end
end
