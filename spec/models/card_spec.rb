require 'spec_helper'

describe Card do
  let(:card){ create(:card)}

  subject{ card }
  
  it{ should respond_to(:created_at)}
  it{ should respond_to(:updated_at)}
  it{ should be_valid}

  describe "evaluable dependency" do
    describe "(presence & validity)" do
      before{ card.evaluable = nil}
      it{ should_not be_valid}
    end
    describe "(destruction)" do
      before{ card.evaluable.destroy}
      it "destroys card" do
        expect( Card.where(id: card.id).count).to eq(0)
      end
      it "destroys reverse card" do
        expect( Card.where(id: card.evaluable.reverse.card.id).count).to eq(0)
      end
    end

    # TODO Should be on the side of evaluation ?
    describe "(reverse destruction)" do
      before{ card.evaluable.reverse.destroy}
      it "destroys card" do
        expect( Card.where(id: card.id).count).to eq(0)
      end
      it "destroys reverse card" do
        expect( Card.where(id: card.evaluable.reverse.card.id).count).to eq(0)
      end
    end
  end

  describe "user dependency" do
    it{ should respond_to(:user_id)}
    it{ should respond_to(:user)}
  end

  describe "list dependency" do
    describe "(presence & validity)" do
      before{ card.list_id = 1111}
      it{ should_not be_valid}
    end

    describe "(destruction)" do
      before{ card.list.destroy}
      it "should not exist anymore" do
        expect( Card.where(id: card.id).count).to eq(0)
      end
    end

    it{ should respond_to(:list_id)}
    it{ should respond_to(:list)}
  end
end
