require 'spec_helper'

describe "ApplicationHelper" do

  describe "full_title" do

    it "should include the application title" do
      expect(full_title("")).to match("#{I18n.t('application.name')}")
    end

    it "should include the page name" do
      expect(full_title("foo")).to match(/foo/)
    end

    it "should not include a bar for the home page" do
      expect(full_title("")).not_to match(/\|/)
    end
  end
end
