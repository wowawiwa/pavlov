require 'spec_helper'

describe ListsController do

  describe "destroy" do
    let(:list){ create(:list)}
    before{ sign_in list.user, no_capybara: true}

    it "should delete" do
      delete 'destroy', id: list.id
      expect(List.where(id: list.id)).to be_empty
    end
  end
end
