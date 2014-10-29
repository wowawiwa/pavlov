require 'spec_helper'

describe Word do
  let(:card){ create(:card)}
  before{ @word = card.evaluable}

  subject{ @word}

  it{ should respond_to(:content)}
  it{ should respond_to(:tip)}
  it{ should be_valid}
  
  context "when content is not valid" do

    context "when empty" do
      before{ @word.content = ""}

      it{ should_not be_valid}
    end

    context "when too long" do
      before{ @word.content = "a"*(APP_SETTINGS[:word_content_max_length]+1)}
      it{ should_not be_valid}
    end
  end

  context "when tip empty" do
    before{ @word.tip = ""}

    it{ should be_valid}
  end

  context "when tip is not valid" do

    context "when too long" do
      before{ @word.tip = "a"*(APP_SETTINGS[:word_tip_max_length]+1)}
      it{ should_not be_valid}
    end
  end
end
