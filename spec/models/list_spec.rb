require 'spec_helper'

describe List do
  let(:list){ create(:list)}

  subject{ list }

  it{ should respond_to(:name)}
  it{ should respond_to(:created_at)}
  it{ should respond_to(:updated_at)}

  describe "(before save normalization)" do
    it "strips leading or trailing spaces before save" do
      list.update_attributes(:name => "   " + list.name + "   ")
      list.reload
      expect(list.name).to eq(list.name.strip)
    end
  end

  describe "(validity)" do
    describe "name" do
      context "when name is empty" do
        before{ list.name = ""}
        it{ should_not be_valid}
      end

      context "when name is too long" do
        before{ list.name = "a"*(APP_SETTINGS[:list_name_max_length]+1)}
        it{ should_not be_valid}
      end
    end
  end

  describe "user dependency" do
    it{ should respond_to(:user_id)}
    it{ should respond_to(:user)}

    describe "(presence & validity)" do
      before{ list.user_id = 111}
      it{ should_not be_valid}
    end

    describe "(destruction)" do
      before{ list.user.destroy}
      it "should not exist anymore" do
        List.where(id: list.id).count.should eq(0)
      end
    end
  end
end

# TODO
# destroy list => destroy all cards, word and word_reverse without deep stack
