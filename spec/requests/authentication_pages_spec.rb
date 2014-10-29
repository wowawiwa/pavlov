require "spec_helper"

describe "Authentication pages" do
  subject{ page}
  let(:user){ create(:user)}

  describe "Sign-In page and submission effect" do
    before{ visit signin_path}
    let(:submit){ "Log in"}
    let(:title){ "Log in"}

    it_behaves_like "title"

    it{ should have_link("Sign up!", href: signup_path)}

    context "with valid information" do
      before do 
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button submit
      end

      it_behaves_like "logged-in"
      it "redirects to the root path" do
        expect( current_path).to eq( root_path)
      end
    end

    context "with invalid information" do
      before{ click_button submit}

      it_behaves_like "title"
      it_behaves_like "flash alert", "warning"
    end
  end

  describe "Sign-Out effect" do
    before do 
      sign_in user
      click_link("Log out")
    end

    it_behaves_like "logged-out"

    it "redirects to the root path" do
      expect( current_path).to eq( root_path)
    end
  end

  describe "Rights" do

    context "as logged-out user" do

      context "when visiting a protected page" do
        it "redirects" do
          get user_path(user)
          expect(response).to redirect_to(signin_path)

          get edit_user_path(user)
          expect(response).to redirect_to(signin_path)

          patch user_path(user)
          expect(response).to redirect_to(signin_path)

          # TODO exhaustive list
        end
      end

      context "when trying to access a protected page while being logged out, it allows to sign in and then redirects to the initialy requested page" do
        before do
          visit edit_user_path(user)
          fill_in "email", with: user.email
          # TODO wrongly send at first
          fill_in "password", with: user.password
          click_button "Log in"
        end
        let(:title){ "Edit profile"}

        it_behaves_like "title"
      end
    end

    context "as illegitimate user" do
      let(:not_me){ create(:user)}
      before{ sign_in user} # TODO why does nt it work with no_capybara: true !?!

      context "when visiting edit page" do
        before{ visit edit_user_path(not_me)}

        #it{ expect(response).to redirect_to(root_url)} # TODO would be better
        it "ignores the given id and acts for the current user" do
          expect(find_field("Nickname").value).to eq(user.name)
        end
      end
    end
  end
end
