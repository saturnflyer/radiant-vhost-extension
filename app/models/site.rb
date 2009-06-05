class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :pages
  
  def allow_access_for(user)
    # Admin can access all sites. Users can only access sites to which they belong
    user.admin? || self.users.include?(user)
  end
  
  def homepage
    self.pages.find(:first, :conditions => {:parent_id => nil})
  end

  def self.find_by_hostname(hostname)
    self.find(:first, :conditions => "hostname LIKE \"%#{hostname}%\"")
  end
end
