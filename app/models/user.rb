class User < ActiveRecord::Base

  has_many :lists, dependent: :destroy
  has_many :cards, dependent: :destroy
  # REM one of:
  #has_many :evaluables, through: :cards, source_type: Word # add #evaluables to the model
  has_many :words, through: :cards, source: :evaluable, source_type: Word # add #words to the model
  has_many :evaluations, through: :cards
  has_many :card_metas, through: :cards, source: :meta

  serialize :guide

  before_save :unconfirm_email, :if => :email_changed?
  before_create :create_remember_token

  before_validation :set_fields_defaults
  before_create :normalize_email

  # TODO add a before_validation: exiger password si email changed

  validates :name, presence: true, length: { maximum: 50 }
  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :email, presence: true, format: { with: EMAIL_FORMAT }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, :if => ->(){ password_digest == nil or self.email_changed? or password != nil} # TODO or password != nil ?!?!
  has_secure_password

  def build_card( evaluable, list={}, card={})
    new_card       = card.kind_of?(Hash) ? cards.find_or_initialize_by( card) : card
    new_card.list  = list.kind_of?(Hash) ? lists.find_or_initialize_by( list) : list
    new_card.evaluable ? new_card.evaluable.assign_attributes( evaluable) : new_card.evaluable = evaluable
    new_card.evaluable.card = new_card # so that evaluable get the card when calling #card before the card is saved
    new_card
  end
  
  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s) # to_s make sure nil token could be handled
  end

  # Email Confirmation

  def email_confirmed?
    return email_confirmed
  end

  def send_email_confirmation!
    if send_email_confirmation_allowed?
      token = User.new_remember_token
      UserMailer.email_confirmation_mail( email, token).deliver
      return update_attributes( email_confirmation_last_sent_date: Time.zone.now, email_confirmation_token: token)
    else
      return false
    end
  end

  def confirm_email!(token)
    if email_confirmation_last_sent_date > 1.day.ago and token == email_confirmation_token
      return update_attributes( email_confirmed: true)
    else
      return false
    end
  end

  def unconfirm_email!
    unconfirm_email
    save
  end

  # Reset password

  def send_password_reset!
    if send_password_reset_allowed?
      token = User.new_remember_token
      UserMailer.password_reset_mail( self, token).deliver
      return update_attributes( password_reset_last_sent_at: Time.zone.now, password_reset_token: token)
    else
      return false
    end
  end

  # return true / false
  def reset_password!(token, password_param)
    if password_reset_last_sent_at > 1.hour.ago and token == password_reset_token
      return update_attributes( password_param.merge!( password_reset_token: nil))
    else
      return false
    end
  end
 
  # TODO: Test if the review starts with the right card
  # RK: Not hooked on the after_create callback not to make tests slow
  def build_initial_content
    path = "content/"
    [
      ["History-50_Most_important_dates", {
        reverse: false,
        chronos_success_min_tspan: 7.days,
        chronos_capacity_volume: 3,
        chronos_capacity_tspan: 7.days,
        review_mail_recurrency: nil

      }],
      ["German_-_From_everyday_life",     { 
        reverse: true,
        chronos_success_min_tspan: 1.hour,
        chronos_capacity_volume: 15,
        chronos_capacity_tspan: 1.day,
        review_mail_recurrency: nil
      }],
      ["What_I_noticed_I_should_do",      {
        reverse: false,
        chronos_success_min_tspan: 1.hour,
        chronos_capacity_volume: nil,
        chronos_capacity_tspan: nil,
        review_mail_recurrency: nil
      }]
    ].each do |filename, config|
      full_path = path + filename + ".csv"
      list = self.lists.create( name: filename.gsub(/_/, " ").gsub(/-/, " - "))
      Pavlov.import_words( File.new(full_path)) do |content, tip|
        build_card( Word.new( content: content, tip: tip), list)
      end
      list.update_attributes( config ) if config
    end
  end

  private

  def unconfirm_email
    self.email_confirmed = false
    self.email_confirmation_token = nil
  end
  
  # TODO manage error display through flash parameter or writting errors in the model.
  # TODO move the 3. hours in a config file ?
  
  def send_email_confirmation_allowed?
    return (not email_confirmed?) && (email_confirmation_last_sent_date == nil || email_confirmation_last_sent_date < 3.hours.ago)
  end

  def send_password_reset_allowed?
    return (password_reset_last_sent_at.nil? or (password_reset_last_sent_at  < 1.hour.ago))
  end

  def create_remember_token
    self.remember_token = User.hash(User.new_remember_token)
  end

  def normalize_email
    email.downcase!
  end

  def set_fields_defaults
    self.guide ||= {}
    raise( "User#guide wrong key") if not self.guide.kind_of?(Hash)
    true
  end
end
