include Vhost::ModelExtensions
module Vhost::PageExtensions
  def self.included(base)
    base.class_eval {
      self.clear_callbacks_by_calling_method_name(:validate, :validates_uniqueness_of)
      validates_uniqueness_of :slug, :scope => [:parent_id, :site_id], :message => 'slug already in use for child of parent'
      validates_presence_of :site_id
      belongs_to :site
    }
  end
end
