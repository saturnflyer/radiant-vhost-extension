require 'yaml'
module Vhost::SiteScopedModelExtensions
  def self.included(base)
    base.class_eval {
      Rails.logger.debug("Applying SiteScope to '"+self.name+"'")
      base.extend(ClassMethods)
      
      self.clear_callbacks_by_calling_method_name(:validate, :validates_uniqueness_of)
      validates_presence_of :site_id
      belongs_to :site

      # Parse the model_uniqueness_validations config and set any necessary validations
      # If the current class name matches an entry in the config then process it
      config = VhostExtension.MODEL_UNIQUENESS_VALIDATIONS[self.name]
      unless config.nil?
        config.each_pair do |attr, params|
          validates_uniqueness_of attr.to_sym, params.symbolize_keys
        end
      end
    }
  end
  module ClassMethods
    def clear_callbacks_by_calling_method_name(kind, calling_method_name)
      calling_method_name = calling_method_name.to_s
      # Callbacks are stored by kind as instance variables named @<kind>_callbacks. 
      # Fetch them so we can kick out the matching items.
      callback_chain = eval("@#{kind.to_s}_callbacks")
      callback_chain.reject! do |callback|
        method = callback.method
        if method.is_a?(Proc)
          # Returns the symbol for the method the proc was declared in
          current_calling_method_name = eval("caller[0] =~ /`([^']*)'/ and $1", method.binding).to_s rescue nil
          current_calling_method_name == calling_method_name
        else
          false
        end
      end
    end
  end
end

