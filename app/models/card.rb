class Card < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :user

  belongs_to :list
  validates_presence_of :list
  validates_associated :list

  # REM autosave: true so that WordReverse and Word are UPDATED when card is updated
  belongs_to :evaluable, polymorphic: true, dependent: :destroy, autosave: true 
  validates_presence_of :evaluable
  validates_associated :evaluable

  has_many :evaluations, dependent: :destroy

  # REM without table name, causes column name ambiguity error when joined.
  scope :desc, ->{ order( "#{table_name}.created_at DESC")}

  after_update :update_reverse_list
  def update_reverse_list
    reverse_card = self.evaluable.reverse.card
    reverse_card.update_attributes( list: self.list) if reverse_card.list != self.list
  end
  
  include Program::Chronos::CardHook
  
end
