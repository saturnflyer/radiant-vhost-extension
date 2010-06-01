class SiteUsersDataset < Dataset::Base
  uses :users
  
  def load
    create_user "UserA"
    create_user "UserB"
    create_user "AdminA", :admin => true, :site_admin => true
    create_user "AdminB", :admin => true
    create_user "DeveloperA", :designer => true
    create_user "DeveloperB", :designer => true
  end
  
  helpers do
    def create_user(name, attributes={})
      create_model :user, name.symbolize, user_attributes(attributes.update(:name => name))
    end
    def user_attributes(attributes={})
      name = attributes[:name] || "John Doe"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "test@example.com", 
        :login => symbol.to_s,
        :password => "password"
      }.merge(attributes)
      attributes[:password_confirmation] = attributes[:password]
      attributes
    end
    def user_params(attributes={})
      password = attributes[:password] || "password"
      user_attributes(attributes).update(:password => password, :password_confirmation => password)
    end
    
    def login_as(user)
      login_user = user.is_a?(User) ? user : users(user)
      # Set the Vhost HOST to the first hostname in the sites list for the user.
      # It works for these tests although it may be problematic as we add more
      # rigorous tests that include multi-site users.
      VhostExtension.HOST = login_user.sites[0].hostname
      flunk "Can't login as non-existing user #{user.to_s}." unless login_user
      request.session['user'] = login_user # Added this because it was in the old PagesController tests
      request.session['user_id'] = login_user.id
      login_user
    end
    
    def logout
      request.session['user_id'] = nil
    end
  end
end