require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SitesController do
  dataset :sites_site_users_and_site_pages

  { :get => [:index, :new, :edit, :remove],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => site_id(:site_a)).should require_login }
      end

      it "should allow you to access to #{action} action if you are an admin" do
        lambda { 
          send(method, action, :id => site_id(:site_a)) 
        }.should restrict_access(:allow => users(:admin),
                                 :url => '/admin/page')
      end
      
      it "should deny you access to #{action} action if you are not an admin" do
        lambda { 
          send(method, action, :id => site_id(:site_a)) 
        }.should restrict_access(:deny => [users(:developer_a), users(:developer_b), users(:user_a), users(:user_b)],
                                 :url => '/admin/page')
      end
    end
  end

end

