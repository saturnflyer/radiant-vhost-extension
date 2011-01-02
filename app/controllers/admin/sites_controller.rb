class Admin::SitesController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy, :switch_to,
    :when => [:admin, :site_admin],
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have site administrative privileges to perform this action.'

  before_filter :ensure_deletable, :only => [:remove, :destory]
    
  def index
    if current_user && current_user.site_admin?
      @sites = Site.all
    elsif current_user && current_user.admin?
      @sites = current_user.sites
    else
      @sites = Array.new
    end

    render
  end

  def ensure_deletable
    if current_site.id.to_s == params[:id].to_s
      announce_cannot_delete_self
      redirect_to admin_sites_url
    end
  end

  def new
    model.hostnames.build
  end
    
  def switch_to
    site = Site.find(params[:id])
    if site
      domain = site.hostnames.first.domain
      domain = request.host if domain == "*"
      redirect_to "http://#{domain}#{request.port.to_s == '80' ? '' : ":#{request.port}"}/admin"
    else
      render :index
    end 
  end
  
  private

  def load_model
    self.model = if params[:id]
      model_class.find(params[:id], :include => [:hostnames])
    else
      model_class.new
    end
  end

  def annouce_cannot_delete_self
    flash[:error] = "You can not delete the current site"
  end

end
