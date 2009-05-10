module Vhost::ReorderExtensions
  module Page
    def self.included(base)
      base.class_eval {
        acts_as_list :scope => [:parent_id, :site_id]
      }
    end
  end
end
