class AddSiteColumns < ActiveRecord::Migration
  
  config = { :site_scoped_models => %w(Layout Page Snippet) }
  begin
    yaml = YAML.load(ERB.new(File.read(RAILS_ROOT + '/config/vhost.yml')).result).symbolize_keys rescue nil
    config.merge!(yaml)
  rescue
  end
  MODELS = config[:site_scoped_models]
  
  # Declare the models so we can use them.
  MODELS.each do |model|
    eval "class #{model} < ActiveRecord::Base; end"
  end
  
  def self.up
    MODELS.each do |model|
      add_column model.tableize, :site_id, :integer
      model.constantize.update_all "site_id = 1"
    end
  end

  def self.down
    MODELS.each do |model|
      remove_column model.tableize, :site_id
    end
  end
end