module Vhost::ActionControllerExtensions
  module DispatcherExtensions
    def self.included(base)
      base.send :before_dispatch, :set_session_domain
    end
      
    def set_session_domain
      if @env['HTTP_HOST']
        domain = @env['HTTP_HOST'].gsub(/:\d+$/, '')
        if domain.match(/([^.]+\.[^.]+)$/)
          domain = '.' + $1
        end

        @env['rack.session.options'][:domain] = domain
      end
    end
  end
  
  def self.included(base)
    base::Dispatcher.send :include, DispatcherExtensions
  end
end
