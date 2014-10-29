# suppose subject is page

shared_examples "title" do |param_title=nil|
  it{ should have_title(full_title(param_title || title))}
  it{ should have_selector('h1', text: (param_title || title))}
end

shared_examples "flash alert" do |status, message=nil, opts={}|
  params = [ "div.alert.alert-#{status}" ]
  if message
    params << { text: message}
  end
  if opts[:should] == false
    it{ should_not have_selector(*params)}
  else
    it{ should have_selector(*params)}
  end
end

# Test if a form-page contains (after one or more submissions) a link to go back to a page the form-page been accessed.
# Assumes:
# * submit variable is the form submit button name
# * Current page links to the form page (which back link is to be tested) through a form_page_link_name link
shared_examples "form back link" do |form_page_link_name, back_link_name=nil, form_fields={}|
  context do # force yielding the context given as block by the user of the example before the following own context.
    let!(:redirect_url){ current_url} # RK note the exclamation mark
    before do
      click_link form_page_link_name
      form_fields.each do |field, value|
        fill_in field, with: value
      end
      click_button submit
    end
    if back_link_name
      # TODO verify the link name
      it{ find(:linkhref, redirect_url).click}
    else
      # just verify presence
      it{ find(:linkhref, redirect_url).click}
    end
  end
end
