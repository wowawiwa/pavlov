class Word < ActiveRecord::Base

  has_one :card, as: :evaluable
  after_destroy :destroy_card

  has_one :word_reverse
  after_save :create_reverse
  after_destroy :destroy_reverse
  def reverse
    word_reverse
  end

  validates :content, presence: true, length: { maximum: APP_SETTINGS[:word_content_max_length]}
  validates :tip, length: { maximum: APP_SETTINGS[:word_tip_max_length]}

  private

  def create_reverse
    word_reverse || self.card.user.build_card( WordReverse.new( word_id: self.id), self.card.list).save
  end

  def destroy_card
    card.destroy if card && !card.destroyed?
  end

  def destroy_reverse
    word_reverse.destroy if word_reverse && !word_reverse.destroyed?
  end
end
