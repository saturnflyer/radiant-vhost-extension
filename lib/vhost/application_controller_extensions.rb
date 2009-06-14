module Vhost::ApplicationControllerExtensions
  def self.included(base)
    base.class_eval {
      prepend_before_filter :redirect_to_primary_site

      def redirect_to_primary_site
        if VhostExtension.REDIRECT_TO_PRIMARY_SITE
          site = current_site
          return if site.nil?
          
          # Rebuild the current URL. Check if it matches the URL of the
          # primary site and redirect if it does not.
          prefix = request.ssl? ? "https://" : "http://"
          host = request.host
          port = request.port_string
          uri = request.request_uri

          # Primary site is the first site
          primary_host = site.hostname.split(',')[0].strip
          full_url = prefix+primary_host+port+uri
          
          redirect_to(full_url) if host != primary_host
        end
      end
    }
  end
end

