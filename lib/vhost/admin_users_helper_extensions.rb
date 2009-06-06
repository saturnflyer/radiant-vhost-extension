module Vhost::AdminUsersHelperExtensions
  def self.included(receiver)
    receiver.send :alias_method_chain, :roles, :site_admin
    receiver.send :define_method, :sites do |user|
      sites = user.sites.collect{|site| site.hostname}
      sites.join("<br/>")
    end
  end
  
  def roles_with_site_admin(user)
    roles = []
    roles << 'Admin' if user.admin?
    roles << 'Site Admin' if user.site_admin?
    roles << 'Developer' if user.developer?
    roles.join(', ')
  end
end
