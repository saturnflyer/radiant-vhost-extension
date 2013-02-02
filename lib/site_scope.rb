module SiteScope
  
  def self.included(base)
    base.send :helper_method, :current_site
  end
  
  def current_site
    return @current_site unless @current_site.nil?
    # For testing we won't have a request.host so we're going to use a class 
    # variable (VhostExtension.HOST) in those cases.
    host ||= VhostExtension.HOST || request.host
    # Remove the 'www.' from the site so we don't have to always include a www. 
    # in addition to the regular domain name.
    host.gsub!(/^www\./, '')
    @current_site ||= Hostname.find_by_domain(host).try(:site) || Hostname.find_by_domain('*').try(:site) || begin Hostname.find(:first).try(:site) rescue raise "No site found to match #{host}." unless @current_site end
    Thread.current[:current_site_id] = @current_site.id
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
    if current_user && current_user.site_admin?
      @users_site_scope = {
        :find => { :joins => "JOIN sites_users AS scoped_sites_users ON scoped_sites_users.user_id = id", :conditions => ["scoped_sites_users.site_id = ?", current_site.id]},
        # Make sure admin is always false - wouldn't want someone trying to set it to true through some html magic
        :create => { :site_ids => [current_site.id], :site_admin => false }
      }
    end
    return @users_site_scope
  end

  # Should this really be here? Shouldn't we be calling this regardless of if we go
  # through the ApplicationControllers :before_filter?
  def set_site_scope_in_models
    set_model_current_site = lambda {|model|
      model.constantize.send :cattr_accessor, :current_site
      model.constantize.current_site = self.current_site
    }
    VhostExtension.MODELS.each do |model|
      set_model_current_site.call(model)
    end
    Site.send :cattr_accessor, :current_site
    Site.current_site = self.current_site
  end
  
end
