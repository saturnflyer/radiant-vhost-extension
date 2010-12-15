class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :pages
  has_many :hostnames, :dependent => :destroy
  
  serialize :config
  
  def title=(val)
    self.config ||= {}
    self.config['title'] = val
  end
  
  def title
    self.config ||= {}
    self.config['title']
  end
  
  def hostname=(val)
    hostname = hostnames.first
    unless hostname
      hostname = Hostname.new
    end
    hostname.update_attributes(:domain => val)
  end
  
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :hostnames, :allow_destroy => true
  VhostExtension.MODELS.each do |model|
    has_many model.tableize.to_sym unless model.tableize.match(/pages|users/) # unless already defined
  end
  
  def allow_access_for(user)
    # Site Admins can access all sites. Users can only access sites to which they belong
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
