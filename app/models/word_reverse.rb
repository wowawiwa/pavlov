class WordReverse < ActiveRecord::Base

  belongs_to :word, autosave: true # REM otherwise, word is not saved when editing the reverse
  validates_presence_of :word
  after_destroy :destroy_word
  def reverse
    word
  end

  has_one :card, as: :evaluable
  after_destroy :destroy_card

  def content
    self.word.tip || "?"
  end

  def content= content
    self.word.tip = content
  end

  def tip
    self.word.content
  end

  def tip= tip
    self.word.content = tip.present? ? tip : "?"
  end

  private

  def destroy_card
    card.destroy if card && !card.destroyed?
  end

  def destroy_word
    word.destroy if word && !word.destroyed?
  end
end
