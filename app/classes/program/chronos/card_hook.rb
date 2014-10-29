# Set the association between Card and the ChronosCard (CardMeta)
module Program::Chronos::CardHook
  ## REM Alternative:
  #extend ActiveSupport::Concern ; included do ... end ;
  def self.included( base)
    base.class_eval do
      has_one :meta, class_name: "CardMeta", dependent: :destroy, :autosave => true
      before_validation{ self.meta ||= CardMeta.new}
      validates_presence_of :meta
      validates_associated :meta
    end
  end
end
