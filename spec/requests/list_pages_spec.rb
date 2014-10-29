require "spec_helper"

describe "List pages" do
  let(:list){ create(:list)}
  before{ sign_in list.user}
    
  subject{ page}

  describe "new list page" # TODO

  describe "edit list page" do
    before{ visit edit_list_path(list)}
    let(:submit){ "Save changes"}
    let(:title){ "List settings"}

    it_behaves_like "title"

    context "with valid information" do
      let(:new_name){ "New list name"}
      before do
        fill_in "Name", with: new_name
        click_button submit
      end

      it_behaves_like "title"
      it_behaves_like "flash alert", "success", "Changes have been save"
      it{ expect(list.reload.name).to eq new_name}
    end

    context "with invalid information" do

      context "with blank name" do
        before do
          fill_in "Name", with: ""
          click_button submit
        end

        it_behaves_like "title"
        it_behaves_like "flash alert", "warning"
      end

      context "with already existing name" do
        let!(:list_with_same_name){ list.user.lists.create(name: "same name")}
        before do
          fill_in "Name", with: "same name"
          click_button submit
        end

        it_behaves_like "title"
        it_behaves_like "flash alert", "warning"
      end
    end
  end # edit
end
