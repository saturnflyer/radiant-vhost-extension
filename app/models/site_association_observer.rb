require 'vhost_extension'
class SiteAssociationObserver < ActiveRecord::Observer
  # observe *VhostExtension::SITE_SPECIFIC_MODELS.collect(&:constantize)
  observe *VhostExtension.MODELS.collect(&:constantize)
  
  def before_validation(model)
    # Set the site_id automatically if it's not already set 
    model.site_id ||= model.class.current_site.id
  end
end
