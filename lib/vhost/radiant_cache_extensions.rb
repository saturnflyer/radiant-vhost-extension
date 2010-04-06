# Alter Radiant's site controller to add the domain to the cache files.
# Also store requests for later use.
# See radiant/app/controllers/site_controller.rb
module Vhost::RadiantCacheExtensions
  module RadiantCache
    def self.included(base)
      base.class_eval {
        # This sets up the cache - the entitystore and metastore 'cache/entity' and 'cache/meta' sets up the folder
        # structure for storing the cache items.
        def self.new(app, options={})
          self.use_x_sendfile = options.delete(:use_x_sendfile) if options[:use_x_sendfile]
          self.use_x_accel_redirect = options.delete(:use_x_accel_redirect) if options[:use_x_accel_redirect]
          Rack::Cache.new(app, {
              :entitystore => "radiant:tmp/cache/entity", 
              :metastore => "radiant:tmp/cache/meta",
              :verbose => false}.merge(options))
        end
        def self.clear(host_and_url = nil)
          meta_stores.each {|ms| ms.clear(host_and_url) }
          entity_stores.each {|es| es.clear }
        end
      }
    end
  end

  module MetaStore
    def self.included(base)
      base.class_eval {
        def initialize(root="#{Rails.root}/cache/meta")
          super
          Radiant::Cache.meta_stores << self
        end
  
        def clear(host_and_url = nil)
          if host_and_url.nil?
            Dir[File.join(self.root, "*")].each {|file| FileUtils.rm_rf(file) }
          else
            FileUtils.rm_rf(key_path("#{host_and_url}"))
          end
        end
  
        def cache_key(request)
          "#{request.host}#{request.path_info}"
        end
      }
    end    
  end

  # FIXME - Add support for EntityStore - MetaStore is the most important caching
  # mechanism to be able to clear by site but EntityStore would be great too.

end
