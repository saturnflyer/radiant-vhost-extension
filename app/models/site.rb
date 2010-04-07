class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :pages
  
  accepts_nested_attributes_for :users
  
  def allow_access_for(user)
    # Site Admin can access all sites. Users can only access sites to which they belong
    user.site_admin? || self.users.include?(user)
  end
  
  def homepage
    self.pages.find(:first, :conditions => {:parent_id => nil})
  end

  def self.find_by_hostname(hostname)
    # allow vhost to be added to existing sites
    if Site.count == 0
      Site.create!(:hostname => hostname)
    end
    self.find(:first, :conditions => ["hostname LIKE ?", "%#{hostname}%"])
  end
end
