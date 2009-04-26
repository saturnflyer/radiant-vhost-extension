class SiteAssociationObserver < ActiveRecord::Observer
  observe *VhostExtension::SITE_SPECIFIC_MODELS.collect(&:constantize)
  
  def before_validation(model)
    model.site_id ||= model.class.current_site.id
  end
=begin    # If there is no site_id yet (new model) then set it to the users site
    # or the "current site". If we have to count on the current_site
    # being set through the use of the request.host property then we can't
    # test this code outside of a web container. This doesn't prevent 
    # someone from creating a model and assigning it to a different site, 
    # it just prevents a model from being created without a site_id.

    if model.respond_to?(:created_by) and not model.created_by.nil? and not model.created_by.site.nil?
      model.site_id ||= model.created_by.site.id
    else
      model.site_id ||= model.class.current_site.id
    end
=end    
end