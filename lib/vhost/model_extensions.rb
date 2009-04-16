module Vhost::ModelExtensions
  def self.included(base)
    base.class_eval {
      base.extend(ClassMethods)
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
        # If it's a Proc then we
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

