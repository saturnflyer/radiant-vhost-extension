module SiteScope
  
  def self.included(base)
    base.send :helper_method, :current_site
  end
  
  def current_site
    # For testing we won't have a request.host so we're going to use a class 
    # variable (VhostExtension.HOST) in those cases.
    host ||= VhostExtension.HOST || request.host
    @current_site ||=  Site.find_by_hostname(host) || Site.find_by_hostname('*')
    raise "No site found to match #{host}." unless @current_site
    @current_site
  end

  protected
  # This is the key method that forks in the additional conditions that will
  # be used to fetch the site-scoped models. It also defines how the site-scoped
  # models will be saved with a site_id.
  def site_scope
    @site_scope ||= {
      :find => { :conditions => ["site_id = ?", current_site.id]},
      :create => { :site_id => current_site.id }
    }
  end

  def users_site_scope
    @users_site_scope = {}
    # Only do the user site scoping if it's a site_admin. We don't want the admin to be restricted.
    if current_user.site_admin?
      @users_site_scope = {
        :find => { :joins => "JOIN sites_users AS scoped_sites_users ON scoped_sites_users.user_id = id", :conditions => ["scoped_sites_users.site_id = ?", current_site.id]},
        # Make sure admin is always false - wouldn't want someone trying to set it to true through some html magic
        :create => { :site_ids => [current_site.id], :admin => false }
      }
    end
    return @users_site_scope
  end

  # Should this really be here? Shouldn't we be calling this regardless of if we go
  # through the ApplicationControllers :before_filter?
  def set_site_scope_in_models
    VhostExtension.MODELS.each do |model|
      model.constantize.current_site = self.current_site
    end
  end
  
end