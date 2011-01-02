ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :sites, :member => {:switch_to => :get}
  end

  map.with_options(:controller => "admin/plans") do |plans|
    plans.gopro 'admin/gopro', :action => 'gopro'
    plans.signup 'admin/signup', :action => 'signup'
  end
end
