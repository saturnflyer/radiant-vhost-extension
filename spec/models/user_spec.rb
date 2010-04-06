require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  dataset :sites_site_users
  test_helper :validations
  
  before :each do
    @model = @user = User.new(user_params)
    @user.confirm_password = false
  end
  
  it 'should have at least one associated site' do
    users(:user_a).should have_at_least(1).sites
  end

end
