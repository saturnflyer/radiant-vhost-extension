module Vhost::AdminExtensionsControllerExtensions
  def self.included(receiver)
    receiver.send :only_allow_access_to, :index,
    :when => :site_admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'
  end
end
