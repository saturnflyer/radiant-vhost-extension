class Admin::SiteController < ApplicationController
  only_allow_access_to :index, :show, :edit, :update,
  :when => :admin,
  :denied_url => { :controller => 'pages', :action => 'index' },
  :denided_message => 'You must have administrative privileges to perform this action.'

  before_filter :load_site

  def show
    set_standard_body_style
    render :edit
  end

  def index
    show
  end

  def edit
    render
  end

  def update
    @site.attributes = params[:site]
    if @site.hostnames.all? { |h| h.marked_for_destruction? }
      flash.now[:error] = "You must keep at least one domain"
      render :edit
    else
      if @site.save
        domain = @site.hostnames.first.domain
        domain = request.host if domain == "*"
        redirect_to "http://#{domain}#{request.port.to_s == '80' ? '' : ":#{request.port}"}/admin/configuration"
      else
        flash.now[:error] = t('preferences_controller.error_updating')
        render :edit
      end
    end
    
  end

  private

  def load_site
    @site = Site.find(current_site.id, :include => [:hostnames])
  end
end
