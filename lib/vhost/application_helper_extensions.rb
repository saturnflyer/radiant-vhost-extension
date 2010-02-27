module Vhost::ApplicationHelperExtensions
  def self.included(receiver)
    # Looks like this swaps out the 'subtitle' method for the 'site_hostname'
    # method to show the hostname in the subtitle in admin...
    receiver.send :alias_method_chain, :subtitle, :site_hostname
    
    receiver.send :define_method, :site_admin? do
      current_user and (current_user.site_admin? or current_user.admin?)
    end
  end
  
  def subtitle_with_site_hostname
    current_site.hostname
  end
end
