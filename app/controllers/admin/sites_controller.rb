class Admin::SitesController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy, :switch_to,
    :when => :site_admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'
    
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

end
