# FIXME - Enable multiple hostnames to be associated with the same site
require 'yaml'
require 'ostruct'
require_dependency 'application_controller'
require File.join(File.dirname(__FILE__), 'vendor/scoped_access/lib/scoped_access')

class VhostExtension < Radiant::Extension
  version "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/VERSION')}"
  description "Host multiple sites on a single instance."
  url "http://github.com/saturnflyer/radiant-vhost-extension"

  # FIXME - Clear up the configuration stuff, it's kinda crufty
  
  class << self
    # Set during tests and used to simulate having a populated request.host
    attr_accessor :HOST
    # Sets the models that are scoped down to a site
    attr_accessor :MODELS
    attr_accessor :MODEL_UNIQUENESS_VALIDATIONS
    attr_accessor :REDIRECT_TO_PRIMARY_SITE
  end
  
  # extension_config do |config|
  #   config.gem 'ancestry'
  # end
  
  def activate
    process_config
    basic_extension_config
    init_scoped_access
    enable_caching
    modify_classes
  end
  
  def deactivate
  end

  def self.read_config
    # Enable quick SiteScoping of other Models via vhost.yml config file
    default_config = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + '/lib/vhost_default_config.yml')).result).symbolize_keys
    begin
      vhost_config_path = RAILS_ROOT + '/config/vhost.yml'
      custom_config = YAML.load(ERB.new(File.read(vhost_config_path)).result).symbolize_keys rescue {}
      default_config[:models].merge!(custom_config[:models]) unless custom_config[:models].blank?
      default_config[:redirect_to_primary_site] = custom_config[:redirect_to_primary_site] unless custom_config[:redirect_to_primary_site].blank?
    end
    config = {}
    config[:redirect_to_primary_site] = default_config[:redirect_to_primary_site]
    config[:models] = default_config[:models].keys
    config[:model_uniqueness_validations] = default_config[:models]
    config
  end
  
  private

  def basic_extension_config
    tab "Settings" do
      add_item "Sites", "/admin/sites"
    end
    admin.user.index.add :thead, 'sites_th', :before => 'modify_header'
    admin.user.index.add :tbody, 'sites_td', :before => 'modify_cell'
    admin.user.edit.add :form, 'admin/users/site_admin_roles', :after => 'edit_roles'
    admin.user.edit.add :form, 'admin/users/edit_sites', :after => 'edit_roles'

    Radiant::AdminUI.class_eval do
      attr_accessor :sites
    end
    # initialize regions for help (which we created above)
    admin.sites = load_default_site_regions
  end
  
  def process_config
    config = VhostExtension.read_config
    
    VhostExtension.REDIRECT_TO_PRIMARY_SITE = config[:redirect_to_primary_site]
    
    # Set the MODELS and MODEL_VALIDATIONS class variables so everything else can access it
    VhostExtension.MODELS = config[:models]
    config[:model_uniqueness_validations].each do |m|
      mklass = m[0].constantize
      mklass.load_subclasses if mklass.respond_to?(:load_subclasses)
      mklass.descendants.each do |desc|
        VhostExtension.MODELS << desc.to_s
      end
      VhostExtension.MODELS << m[1]['sti_classes'] unless m[1]['sti_classes'].blank?
    end
    #flatten and uniq on self
    VhostExtension.MODELS.flatten!
    VhostExtension.MODELS.uniq!
    VhostExtension.MODEL_UNIQUENESS_VALIDATIONS = config[:model_uniqueness_validations]
  end
  
  def init_scoped_access  
    controllers = []    
    # load all controllers
    ([RADIANT_ROOT] + Radiant::Extension.descendants.map(&:root)).each do |path|
      Dir["#{path}/app/controllers/**/*.rb"].each do |controller|
        controller_class = controller.sub("#{path}/app/controllers/",'').sub(/\.rb$/,'').camelize
        begin
          controllers << controller_class.constantize if controller_class.constantize.new.is_a?(ApplicationController)
        rescue
          Rails.logger.info "#{controller} could not be loaded"
        end
      end
    end 
    
    VhostExtension.MODELS.each do |vmodel|
      controllers.each do |controller| controller.send :prepend_around_filter, ScopedAccess::Filter.new(vmodel.constantize, :site_scope) end
      klass = vmodel.constantize
      klass.class_eval {
        cattr_accessor :current_site
        extend Vhost::SiteScopedModelExtensions::ClassMethods
        include Vhost::SiteScopedModelExtensions::InstanceMethods
      }
    end
    
    ApplicationController.class_eval {
      include SiteScope
      before_filter :set_site_scope_in_models
    }
    
    # # Enable instance level calls like 'my_layout.current_site' for each model (overkill?)
    controllers.each do |controller| controller.send :before_filter, :set_site_scope_in_models end

    # Wrap UsersController with site scoping for Site Admins
    Admin::UsersController.send :prepend_around_filter, ScopedAccess::Filter.new(User, :users_site_scope)
  end
  
  def enable_caching
    # Enable caching per site
    Radiant::Cache.send :include, Vhost::RadiantCacheExtensions::RadiantCache
    Radiant::Cache::MetaStore.send :include, Vhost::RadiantCacheExtensions::MetaStore
    Admin::PagesController.send :include, Vhost::PagesControllerExtensions
  end
  
  def modify_classes
    # Send all of the Vhost extensions and class modifications 
    User.send :has_and_belongs_to_many, :sites
    ApplicationHelper.send :include, Vhost::ApplicationHelperExtensions
    Admin::UsersHelper.send :include, Vhost::AdminUsersHelperExtensions
    Admin::UsersController.send :include, Vhost::AdminUsersControllerExtensions
    # Prevents a user from Site A logging into Site B's admin area (need a spec
    # for this to ensure it's working)
    Admin::ResourceController.send :include, Vhost::ControllerAccessExtensions
    Admin::PagesController.send :include, Vhost::ControllerAccessExtensions 
    ApplicationController.send :include, Vhost::ApplicationControllerExtensions 
  end

  # Defines this extension's default regions (so that we can incorporate shards
  # into its views).
  def load_default_site_regions
    returning OpenStruct.new do |site|
      site.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_title edit_hostname edit_users}
        edit.form_bottom.concat %w{edit_buttons}
      end
      site.new = Radiant::AdminUI::RegionSet.new do |new|
        new.main.concat %w{edit_header edit_form}
        new.form.concat %w{edit_title edit_hostname edit_users}
        new.form_bottom.concat %w{edit_buttons}
      end
    end
  end
  
end
