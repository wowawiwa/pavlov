shared_examples "logged-out" do

  it_behaves_like "logged-out layout"

  # TODO root path shows "Welcome"
  # ...
end

shared_examples "logged-in" do

  it_behaves_like "logged-in layout"
end
