require "spec_helper"

describe "Static pages" do
  shared_examples_for "all static pages" do
    it { should have_selector("h1", text: heading) }
    it { should have_title(full_title(page_title)) }
  end
  subject { page }

  describe "Welcome" do
    before { visit root_path}
    let(:heading) { "Pavlov" }
    let(:page_title) { "" }

    it_behaves_like "logged-out"

    it_should_behave_like "all static pages"

    it { should_not have_title("| Pavlov") }

    it "has Sign Up link" do
      within('.col-md-4') do
        click_link "Sign up"
        expect(page).to have_title(full_title("Sign up"))
      end
    end

    it "has intro text" do
      expect(page).to have_content("get into new habits")
    end
  end

  describe "About" do
    before { visit about_path }
    let(:heading) { "About" }
    let(:page_title) { "About" }

    it_should_behave_like "all static pages"
  end

  describe "Contact" do
    before { visit contact_path }
    let(:heading) { "Contact" }
    let(:page_title) { "Contact" }

    it_should_behave_like "all static pages"
  end

  describe "KBShortcut" do
    before{ visit kbshortcuts_path }
    let(:heading) { "Keyboard Shortcuts" }
    let(:page_title) { "Keyboard Shortcuts" }

    it_should_behave_like "all static pages"
  end

  describe "Help" do
    before{ visit help_path }
    let(:heading) { "Help" }
    let(:page_title) { "Help" }

    it_should_behave_like "all static pages"
  end
end
