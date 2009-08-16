module Vhost::ApplicationControllerExtensions
  def self.included(base)
    base.class_eval {
      prepend_before_filter :redirect_to_primary_site

      helper_method :primary_site_url
      
      def redirect_to_primary_site
        if VhostExtension.REDIRECT_TO_PRIMARY_SITE
          site = current_site
          return if site.nil? || site.hostname.include?("*")
          primary_host = site.hostname.split(',')[0].strip
          redirect_to(primary_site_url + request.request_uri) if request.host != primary_host
        end
      end

      def primary_site_url
          site = current_site
          return nil if site.nil? || site.hostname.include?("*")

          # Rebuild the current URL. Check if it matches the URL of the
          # primary site and redirect if it does not.
          prefix = request.ssl? ? "https://" : "http://"
          host = request.host
          port = request.port_string

          # Primary site is the first site
          primary_host = site.hostname.split(',')[0].strip
          
          # Return the concatenation
          prefix+primary_host+port
      end
    }
  end
end

