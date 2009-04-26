include Vhost::ModelExtensions
module Vhost::UserExtensions
  def self.included(base)
    base.class_eval {
      # Users can belong to multiple sites
      has_and_belongs_to_many :sites
    }
  end
end
