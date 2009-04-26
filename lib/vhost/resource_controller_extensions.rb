module Vhost::ResourceControllerExtensions
  def self.included(receiver)
    receiver.send :before_filter, :ensure_user_has_site_access
  end
  
  def ensure_user_has_site_access
    unless current_site.allow_access_for(current_user)
      cookies[:session_token] = { :expires => 1.day.ago }
      self.current_user.forget_me if self.current_user
      self.current_user = nil
      flash[:error] = 'Access denied.'
      redirect_to login_url
#      redirect_to :controller => 'welcome', :action => 'login'
    end
  end
end

