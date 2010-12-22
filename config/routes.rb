ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :sites, :member => {:switch_to => :get}
  end

  map.namespace :admin do |admin|
    admin.resources :site, :controller => 'site'
  end
end
