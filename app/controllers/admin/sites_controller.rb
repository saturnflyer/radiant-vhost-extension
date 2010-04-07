class Admin::SitesController < Admin::ResourceController
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy, :switch_to,
    :when => :site_admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'
    
  def switch_to
    site = Site.find(params[:id])
    if site
      redirect_to "http://#{site.hostname}#{request.port == '80' ? '' : ":#{request.port}"}/admin"
    else
      render :index
    end 
  end

end
