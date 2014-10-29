shared_examples "logged-out layout" do |page_param=nil|
  describe "header" do
    it_behaves_like "logged-out header"
  end

  describe "footer" do
    it_behaves_like "footer"
  end
end

shared_examples "logged-in layout" do |page_param=nil|
  describe "header" do
    it_behaves_like "logged-in header"
  end

  describe "footer" do
    it_behaves_like "footer"
  end
end

shared_examples "logged-out header" do |page_param=nil|
  it "does contain links with the right names, going to the aimed places" do
    page_param ||= page
    within('header') do
      expect(page).to have_link("PA/LOV", href: root_path)
      expect(page).to have_link("Sign in", href: signin_path)
    end
  end
end

shared_examples "logged-in header" do |user_param=nil, page_param=nil|
  it "does contain links with the right names, going to the aimed places" do
    page_param ||= page
    user_param ||= user
    within('header') do
      expect(page).to have_link("PA/LOV", href: root_path)
      expect(page).to have_link("Card", href: new_card_path)
      expect(page).to have_link("List", href: new_list_path)
      expect(page).to have_link("Help", href: help_path)
      expect(page).to have_link("Shortcuts", href: kbshortcuts_path)
      expect(page).to have_link("Profile", href: user_path(user))
      expect(page).to have_link("Sign out", href: signout_path)
    end
  end
end

shared_examples "footer" do |page_param=nil|
  it "does contain links with the right names, going to the aimed places" do
    page_param ||= page
    within('footer') do
      expect(page).to have_link("About", href: about_path)
      expect(page).to have_link("Contact", href: contact_path)
    end
  end
end
