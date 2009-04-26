module Vhost::ApplicationHelperExtensions
  def self.included(receiver)
    # Looks like this swaps out the 'subtitle' method for the 'site_hostname'
    # method to show the hostname in the subtitle in admin...
    receiver.send :alias_method_chain, :subtitle, :site_hostname
  end
  
  def subtitle_with_site_hostname
    current_site.hostname
  end
end
