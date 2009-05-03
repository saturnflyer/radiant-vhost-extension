# You'll need this if you are going to add regions into your extension interface.
require 'ostruct'
require_dependency 'application'
require File.join(File.dirname(__FILE__), 'lib/scoped_access_init')
require File.join(File.dirname(__FILE__), 'vendor/scoped_access/lib/scoped_access')

class VhostExtension < Radiant::Extension
  version "2.0"
  description "Host multiple sites on a single instance."
  url "http://github.com/jgarber/radiant-vhost-extension"

  # This will be set during tests and used to simulate having a populated request.host
  class << self
    attr_accessor 'HOST'
  end

  # This constant sets the models that are scoped down to a site
  SITE_SPECIFIC_MODELS = %w(Layout Page Snippet)
  
  # These routes are added to the radiant routes file and works just like any rails routes.
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :sites
    end
  end
  
  def activate
    admin.tabs.add "Sites", "/admin/sites", :after => "Layouts", :visibility => [:admin]

    # This adds information to the Radiant interface. In this extension, we're dealing with "site" views
    # so :sites is an attr_accessor. If you're creating an extension for tracking moons and stars, you might
    # put attr_accessor :moon, :star
    Radiant::AdminUI.class_eval do
      attr_accessor :sites
    end
    # initialize regions for help (which we created above)
    admin.sites = load_default_site_regions

    # Configure the ScopedAccess stuff to scope models to Sites
    # Unfortunately adding the filters to the ApplicationController isn't enough
    # they need to also be added to all of the subclasses (which, surprisingly
    # only shows as the Admin::PagesController and Admin::ResourceController)
    controllers = ['ApplicationController']
    controllers.concat ApplicationController.subclasses
    controllers.each do |controller| controller.constantize.send :include, SiteScope end
  
    VhostExtension::SITE_SPECIFIC_MODELS.each do |model|
      # Instantiate the ScopedAccess filter for each model
      controllers.each do |controller| controller.constantize.send :prepend_around_filter, ScopedAccess::Filter.new(model.constantize, :site_scope) end
      # Enable class level calls like 'Layout.class.current_site' for each model
      model.constantize.send :cattr_accessor, :current_site
    end
    # Enable instance level calls like 'my_layout.current_site' for each model
    controllers.each do |controller| controller.constantize.send :before_filter, :set_site_scope_in_models end

    # Enable caching per site by rewriting the show_page method
    SiteController.send :alias_method, :show_page_orig, :show_page
    SiteController.send :remove_method, :show_page
    SiteController.send :include, CacheByDomain

    # Send all of the Vhost extensions and class modifications 
    User.send :include, Vhost::UserExtensions
    Page.send :include, Vhost::PageExtensions
    Snippet.send :include, Vhost::SnippetExtensions
    Layout.send :include, Vhost::LayoutExtensions
    ApplicationHelper.send :include, Vhost::ApplicationHelperExtensions
    Admin::ResourceController.send :include, Vhost::ResourceControllerExtensions
    Admin::PagesController.send :include, Vhost::PagesControllerExtensions

    # SUPPORT FOR OTHER EXTENSIONS
    # I'm sure there's an DRYer way to do these checks, doing it the poor way for now.
    
    # FCKeditor
    fck = Kernel.const_get("FckeditorExtension") rescue false
    if fck
      FckeditorController.send :remove_method, :current_directory_path
      FckeditorController.send :remove_method, :upload_directory_path
      FckeditorController.send :include, Vhost::FckeditorExtensions::Controller
    end
    
  end
  
  def deactivate
    admin.tabs.remove "Sites"
  end
  
  private
  
  # Defines this extension's default regions (so that we can incorporate shards
  # into its views).
  def load_default_site_regions
    returning OpenStruct.new do |site|
      site.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_hostname edit_users}
        edit.form_bottom.concat %w{edit_buttons}
      end
      site.new = Radiant::AdminUI::RegionSet.new do |new|
        new.main.concat %w{edit_header edit_form}
        new.form.concat %w{edit_hostname edit_users}
        new.form_bottom.concat %w{edit_buttons}
      end
    end
  end
  
end
