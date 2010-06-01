module Vhost::AdminUsersControllerExtensions
  def self.included(receiver)
    receiver.send  :only_allow_access_to, :index, :show, :new, :create, :edit, :update, :remove, :destroy,
      :when => [:admin, :site_admin], 
      :denied_url => { :controller => 'pages', :action => 'index' },
      :denied_message => 'You must have administrative privileges to perform this action.'

    receiver.class_eval {
      def load_model
        self.model = if params[:id]
          model_class.find(params[:id], :readonly => false)
        else
          model_class.new
        end
      end
      
      def load_models
        self.models = current_site.users.paginate(pagination_parameters)
      end
    }
  end
end
