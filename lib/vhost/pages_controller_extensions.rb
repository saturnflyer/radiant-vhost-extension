module Vhost::PagesControllerExtensions
  def self.included(receiver)
    receiver.send :alias_method_chain, :clear_model_cache, :site_specificity
  end
  
  def clear_model_cache_with_site_specificity
    url_to_expire = "#{request.host}#{@page.url}"
    Radiant::Cache.clear(url_to_expire) if defined?(Radiant::Cache)
  end
end

