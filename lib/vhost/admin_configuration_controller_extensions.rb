module Vhost::AdminConfigurationControllerExtensions
  def self.included(receiver)
    receiver.send :only_allow_access_to, :edit, :update,
    :when => [:site_admin],
    :denied_url => { :controller => 'admin/configuration', :action => 'show' },
    :denied_message => 'You must have admin privileges to edit site configuration.'
  end
end
