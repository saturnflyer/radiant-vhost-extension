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

  # Should this really be here? Shouldn't we be calling this regardless of if we go
  # through the ApplicationControllers :before_filter?
  def set_site_scope_in_models
    VhostExtension::SITE_SPECIFIC_MODELS.each do |model|
      model.constantize.current_site = self.current_site
    end
  end
  
end