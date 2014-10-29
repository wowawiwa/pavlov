class CardMeta < ActiveRecord::Base
  self.table_name = "card_metas"

  belongs_to :card
  validates_presence_of :card
  validates_uniqueness_of :card

  has_many :evaluations, through: :card
  has_one :list, through: :card

  serialize :previous
  validates :next_evaluation_date, presence: true

  scope :next_eval_after, lambda{|date| where("next_evaluation_date > ?", date)}
  scope :next_eval_before, lambda{|date| where("next_evaluation_date <= ?", date)}
  scope :once_evaluated, lambda{ where.not( last_evaluation_date: nil)}
  scope :never_evaluated, lambda{ where( last_evaluation_date: nil)}
  scope :exclude_x_most_recently_evaluated, lambda{|number_to_exclude| order("last_evaluation_date ASC").limit( [ count - number_to_exclude, 0].max)}
  scope :exclude_x_most_recently_reverse_evaluated, lambda{|after| where("(reverse_last_evaluation_date IS NULL) OR (reverse_last_evaluation_date < ?)", after) }
  # Not used:
  #scope :exclude_evaled_in_the_last, lambda{|timespan, now=Time.zone.now| where("last_evaluation_date <= ?", now - timespan)}
  #scope :only_evaled_in_the_last, lambda{|timespan, now=Time.zone.now| where("last_evaluation_date > ?", now - timespan)}

  before_validation :set_defaults

  # Supposes the scope is self.list
  # If other kind of scope should be supported, report_result should be called should be called by the review controller with a scope object.
  def report_result correction=false
    save_xor_restore_state! !correction
    new_state = {}
    yield(self.attributes, new_state)
    self.assign_attributes(new_state)
    save!
    self.card.evaluable.reverse.card.meta.update_attributes( reverse_last_evaluation_date: Time.zone.now)
    return
  end

  private

  def set_defaults
    self.next_evaluation_date ||= Time.zone.now
  end

  def save_xor_restore_state!(to_save=true)
    if to_save
      self.previous = self.attributes.except("previous")
    else
      self.assign_attributes( self.previous) if self.previous
    end
  end
end
