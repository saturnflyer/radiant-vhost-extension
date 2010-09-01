module ActiveRecord::ConnectionAdapters::SchemaStatements
  def add_index_with_quiet(table_name, column_names, options = {})
    quiet = options.delete(:quiet)
    add_index_without_quiet table_name, column_names, options
  rescue
    raise unless quiet and $!.message =~ /^Mysql::Error: Duplicate key name/i
    puts "Failed to create index #{table_name} #{column_names.inspect} #{options.inspect}"
  end
  alias_method_chain :add_index, :quiet

  def remove_index_with_quiet(table_name, column_names, options = {})
    quiet = options.delete(:quiet)
    raise "no options allowed for remove_index, except quiet with this hack #{__FILE__}:#{__LINE__}" unless options.empty?
    remove_index_without_quiet table_name, column_names
  rescue
    raise unless quiet and $!.message =~ /^Mysql::Error: Can't DROP/i
    puts "Failed to drop index #{table_name} #{column_names.inspect}"
  end
  alias_method_chain :remove_index, :quiet
end

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
        puts "Migrations for Model: #{model}"
        add_column model.tableize, :site_id, :integer
        model.constantize.update_all "site_id = 1"
      rescue StandardError => e
        puts "Migration failed for: #{e.inspect}"
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
        # Special case for Snippets to add a proper index
        if model == 'Snippet'
          remove_index :snippets, :name => "name"
          add_index :snippets, [:name, :site_id], :name => "name", :unique => true
        end
        if model == 'MetaTag'
          add_index :meta_tags, [:name, :site_id], :unique => true
          remove_index :meta_tags, [:name]
        end
    end
  end

  def self.down
    MODELS.each do |model|
      begin
      rescue
        puts "Migration failed for: #{e.inspect}"
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
      # Special case for Snippets to remove index
      if model == 'Snippet'
        remove_index :snippets, [:name, :site_id]
        add_index :snippets, [:name],:name => "name", :unique => true
      end
      if model == 'MetaTag'
        remove_index :meta_tags, [:name, :site_id]
        add_index :meta_tags, [:name], :unique => true
      end
      remove_column model.tableize, :site_id
    end
  end
end
 