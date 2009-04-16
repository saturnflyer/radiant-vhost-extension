include Vhost::ModelExtensions
module Vhost::LayoutExtensions
  def self.included(base)
    base.class_eval {
      self.clear_callbacks_by_calling_method_name(:validate, :validates_uniqueness_of)
      validates_uniqueness_of :name, :message => 'name already in use', :scope => :site_id
      validates_presence_of :site_id
    }
  end
end

