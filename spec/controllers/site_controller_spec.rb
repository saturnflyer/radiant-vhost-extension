require File.dirname(__FILE__) + '/../spec_helper'

describe SiteController do
  dataset :sites_site_users_and_site_pages, :site_home_pages
  before(:each) do
    logout
    VhostExtension.HOST = sites(:site_a).hostnames.first.domain # Pretend we're connected to site_a so the SiteScope works right
    rescue_action_in_public!  # ActionController::TestCase no longer considers this request a local request

    # don't bork results with stale cache items
    Radiant::Cache.clear
  end

  it "should find and render the home page for the #{VhostExtension.HOST} site" do
    get :show_page, :url => '/'
    response.should be_success
    response.body.should == 'Hello A'
  end

  it "should find and render a child page for the #{VhostExtension.HOST} site" do
    get :show_page, :url => 'page-a/'
    response.should be_success
    response.body.should == 'PageA Body'
  end

  it "should NOT find and render a child page for a site other than the #{VhostExtension.HOST} site" do
    get :show_page, :url => 'page-b/'
    response.should be_missing
  end

end

