class AddSiteColumns < ActiveRecord::Migration
  
  config = VhostExtension.read_config

  MODELS = config[:models]
  
  # Declare the models so we can use them.
  MODELS.each do |model|
    eval "class #{model} < ActiveRecord::Base; end"
  end
  
  def self.up
    MODELS.each do |model|
      begin
        add_column model.tableize, :site_id, :integer
        model.constantize.update_all "site_id = 1"
      rescue
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
    end
    add_index :snippets, [:name, :site_id] rescue nil
  end

  def self.down
    MODELS.each do |model|
      begin
        remove_column model.tableize, :site_id
      rescue
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
    end
    remove_index :snippets, :column => [:name, :site_id] rescue nil
  end
end
