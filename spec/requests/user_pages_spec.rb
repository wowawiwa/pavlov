require "spec_helper"

describe "User pages" do
  subject{ page}

  describe "profile page" do
    let(:user){ create(:user)}
    before do
      sign_in user
      visit user_path(user) # set the "page" variable
    end  
    let(:title){ "Profile"}

    it_behaves_like "title"
    it{ should have_content(user.email)}
    it{ should have_content(user.name)}
    it{ should have_link("Edit profile", href: edit_user_path(user))}
  end

  describe "sign up page" do
    before{ visit signup_path}
    let(:user){ build(:user)}
    let(:submit){ "Join"}
    let(:title){ I18n.t('application.name')}

    describe "with valid information" do
      before do
        fill_in "user[name]", with: user.name
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        click_button submit
      end

      it "should create a new user" do
        expect( User.where(email: user.email.downcase).count).to eq(1)
      end

      context "after saving the user" do
        let(:title){ "Home"} 

        it{ should have_link("Log out")}
        it_behaves_like "title"

        context "after sign out" do
          before{ click_link "Log out"}
          
          it{ should have_link("Log in")}
        end
      end
    end

    describe "with invalid information" do
      it "should not create a new user" do
        expect{ click_button submit}.not_to change(User, :count)
      end

      before{ click_button submit}

      it_behaves_like "flash alert", "warning"
    end
  end

  describe "edit page" do
    let(:submit){ "Save changes"}
    let(:user){ create(:user)}
    before do 
      sign_in user
      visit edit_user_path(user)
    end
    let(:title){ "Edit profile"}

    it_behaves_like "title"

    context "with valid information" do
      let(:new_name){ "New Name"}
      let(:new_email){ "new_email@example.com"}
      let(:title){ "Profile"}

      before do
        fill_in "Nickname", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Password confirmation", with: user.password
        click_button submit
      end

      it_behaves_like "title"
        it_behaves_like "flash alert", "success", "Changes have been saved"
      it{ expect(user.reload.name).to eq new_name}
      it{ expect(user.reload.email).to eq new_email}
    end

    context "with invalid information" do
      before do
        fill_in "Nickname", with: "another_nick"
        fill_in "user[email]",  with: "updated@.com"
        click_button submit
      end

      it_behaves_like "flash alert", "warning"
      it{ expect(user.reload.name).to eq(user.name)}
    end
  end
end
