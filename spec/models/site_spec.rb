require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  dataset :site_users
  
  before(:each) do
    @site = Site.new(:title => "site")
  end

  it "should be valid" do
    @site.should be_valid
  end

  it "should allow users to be associated" do
    user = users(:usera)
    @site.users << user
    @site.users.should have(1).items
  end
end
