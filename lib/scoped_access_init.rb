##
##  scoped_access/init.rb handles Rails 1.2, 2.0, and 2.1, but the version
##  Radiant is using, 2.0.2, falls through the cracks. This fixes that.
##

ActionController::Base.instance_eval do
  def scoped_access (*args, &block)
    options = (Hash === args.last && !(args.last.keys & [:only, :except]).empty?) ? args.pop : {}
    send(:around_filter, ScopedAccess::Filter.new(*args, &block), options)
  end
end

require 'dispatcher'
  # Rails1.2 or Rails2.0
  class ::Dispatcher
    app = respond_to?(:prepare_application, true) ? (class << self; self end) : self
    app.class_eval do
      private

      # Added to get 'prepare_application' error to go away
      def prepare_application
         new(STDOUT).reload_application
      end

      def reset_application
         new(STDOUT).cleanup_application
      end

      def prepare_application_with_reset
        ScopedAccess.reset
        prepare_application_without_reset
      end

      alias_method :prepare_application_without_reset, :prepare_application
      alias_method :prepare_application, :prepare_application_with_reset
    end
  end
# end

ActiveRecord::Base.instance_eval do
  def reset_scope
    scoped_methods.clear
  end
end
