class Site < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :pages
  has_many :hostnames, :dependent => :destroy

  validates_presence_of :title
  
  serialize :config

  after_create :build_template
  
  def expires=(val)
    self.config ||= {}
    self.config['expires'] = val
  end

  def expires
    self.config ||= {}
    self.config['expires']
  end

  def storage=(val)
    self.config ||= {}
    self.config['storage'] = val
  end

  def storage
    self.config ||= {}
    self.config['storage'] || 52428800
  end

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
      hostname.site = self
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

  private

  def build_template
    path = "#{RAILS_ROOT}/vendor/extensions/vhost/db/templates/client"
    layout = Layout.new(:name => "Template", :content => File.new("#{path}/layout.html").read)
    layout.site = self
    layout.save!
    home = Page.new_with_defaults
    home.site = self
    home.update_attributes!(:title => "Home", :breadcrumb => "Home", :slug => "/", :status => Status[:published], :layout => layout)
    home.part(:body).update_attributes!(:content => File.new("#{path}/home.html").read)
    css = StylesheetPage.new_with_defaults
    css.site = self
    css.update_attributes!(:slug => "css", :parent => home)
    js = JavascriptPage.new_with_defaults
    js.site = self
    js.update_attributes!(:slug => "js", :parent => home)
    style = StylesheetPage.new_with_defaults
    style.site = self
    style.update_attributes!(:slug => "style.css", :parent => css)
    style.part(:body).update_attributes!(:content => File.new("#{path}/style.css").read)
    code = JavascriptPage.new_with_defaults
    code.site = self
    code.update_attributes!(:slug => "code.js", :parent => js)
    code.part(:body).update_attributes!(:content => File.new("#{path}/code.js").read)
  end

end
