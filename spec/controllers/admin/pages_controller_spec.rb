require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  dataset :sites_site_users_and_site_pages
  
  before :each do
    VhostExtension.HOST = sites(:site_a).hostnames.first.domain # Pretend we're connected to site_a so the SiteScope works right
    rescue_action_in_public!  # ActionController::TestCase no longer considers this request a local request

    # don't bork results with stale cache items
    Radiant::Cache.clear
    login_as :usera
  end

  describe "creating pages" do
    
    it "should be associated with the site corresponding to the current hostname" do
      # Need to call get :new or else the :before_filter in the ApplicationController
      # that sets up the SiteScope doesn't run.
      slug = "should-be-associated-with-site"
      post :create, :page => page_params(:slug => slug)
      Page.find_by_slug(slug).site.id.should == site_id(:site_a)
    end
    
  end

  describe "permissions" do

    # @todo it "should allow <various> actions for users that belong to multiple sites" 
    # (or something like that. probably just hook into the block below.)
  
    [:admina, :developera, :usera].each do |user|
      {
        :post => :create,
        :put => :update,
        :delete => :destroy
      }.each do |method, action|
        it "should allow the #{action} action to a page belonging to a site #{user.to_s.humanize} has access to" do
          login_as user
          send method, action, :id => page_id(:page_a)
          response.should redirect_to('admin/pages')
        end
      end
    end

    [:developera, :usera].each do |user|
      {
        :post => :create,
        :put => :update,
        :delete => :destroy
      }.each do |method, action|
        it "should show a missing page (404) for the #{action} action on a page NOT belonging to a site #{user.to_s.humanize} has access to" do
          login_as user
          send method, action, :id => page_id(:page_b)
          response.should be_missing
        end
      end
    end

  end


=begin
  
  describe "permissions" do
    
    [:admin, :developer, :non_admin, :existing].each do |user|
      {
        :post => :create,
        :put => :update,
        :delete => :destroy
      }.each do |method, action|
        it "should require login to access the #{action} action" do
          logout
          send method, action, :id => Page.first.id
          response.should redirect_to('/admin/login')
        end
        
        it "should allow access to #{user.to_s.humanize}s for the #{action} action" do
          login_as user
          send method, action, :id => Page.first.id
          response.should redirect_to('/admin/pages')
        end
      end
    end
    
    [:index, :show, :new, :edit, :remove].each do |action|
      before :each do
        @parameters = lambda do 
          case action
          when :index
            {}
          when :new
            {:page_id => page_id(:home)}
          else
            {:id => Page.first.id} 
          end
        end
      end
      
      it "should require login to access the #{action} action" do
        logout
        lambda { send(:get, action, @parameters.call) }.should require_login
      end

      it "should allow access to admins for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:admin)], 
                                 :url => '/admin/pages')
      end

      it "should allow access to developers for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/pages')
      end
    
      it "should allow non-developers and non-admins for the #{action} action" do
        lambda { 
          send(:get, action, @parameters.call) 
        }.should restrict_access(:allow => [users(:non_admin), users(:existing)],
                                 :url => '/admin/pages')
      end
    end
  end
  
  
  describe "prompting page removal" do
    integrate_views
    
    # TODO: This should be in a view or integration spec
    it "should render the expanded descendants of the page being removed" do
      get :remove, :id => page_id(:parent), :format => 'html' # shouldn't need this!
      rendered_pages = [:parent, :child, :grandchild, :great_grandchild, :child_2, :child_3].map {|p| pages(p) }
      rendered_pages.each do |page|
        response.should have_tag("tr#page-#{page.id}")
      end
    end
  end
  
  it "should initialize meta and buttons_partials in new action" do
    get :new, :page_id => page_id(:home)
    response.should be_success
    assigns(:meta).should be_kind_of(Array)
    assigns(:buttons_partials).should be_kind_of(Array)
  end

  it "should initialize meta and buttons_partials in edit action" do
    get :edit, :id => page_id(:home)
    response.should be_success
    assigns(:meta).should be_kind_of(Array)
    assigns(:buttons_partials).should be_kind_of(Array)
  end
  
  protected

    def assert_rendered_nodes_where(&block)
      wanted, unwanted = Page.find(:all).partition(&block)
      wanted.each do |page|
        response.should have_tag("tr#page-#{page.id}")
      end
      unwanted.each do |page|
        response.should_not have_tag("tr#page-#{page.id}")
      end
    end

    def write_cookie(name, value)
      request.cookies[name] = CGI::Cookie.new(name, value)
    end
=end
end
