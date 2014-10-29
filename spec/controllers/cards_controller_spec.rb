require 'spec_helper'

describe CardsController do

  describe "#destroy" do
    let(:card){ create(:card)}
    before do
      sign_in card.list.user, no_capybara: true
    end

    it "should delete" do
      delete 'destroy', id: card.id
      expect(Card.where(id: card.id)).to be_empty
    end
  end
end
