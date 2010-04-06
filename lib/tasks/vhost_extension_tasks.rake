namespace :radiant do
  namespace :extensions do
    namespace :vhost do
      
      desc "Prepares your database for Vhost"
      task :install => [:environment, :migrate, :apply_site_scoping]
      
      desc "Runs the migration of the Vhost extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          VhostExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          VhostExtension.migrator.migrate
        end
      end

      
      # @todo the following method should accept a direction. We should also
      # rename it something like 'apply_site_scoping' and 'reset_site_scoping' 
      # or something...
      desc "Initializes site scoping. "
      task :apply_site_scoping => :environment do
        require "#{File.dirname(__FILE__)}/add_site_columns"
        AddSiteColumns.up
      end
      
      desc "Reinitializes site scoping in the event a new model needs to be site scoped."
      task :reset_site_scoping => :environment do
        require 'highline/import'
        if agree("This task will destroy any model to site relationships in the database. Are you sure \nyou want to continue? [yn] ")
          AddSiteColumns.up
          AddSiteColumns.down
        end
      end
    
    end
  end
end

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
 
def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

# We need the bootstrap task to use site_ids
remove_task "db:bootstrap"
remove_task "db:remigrate"
namespace :db do  
  desc "Bootstrap your database for Radiant."
  task :bootstrap => :remigrate do
    require 'radiant/setup'
    require File.join(File.dirname(__FILE__), '../bootstrap_with_site_id')
    Radiant::Setup.send :include, BootstrapWithSiteId
    Radiant::Setup.send :alias_method_chain, :load_database_template, :site_id
    Radiant::Setup.send :alias_method_chain, :find_template_in_path, :site_id
    
    Radiant::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )

    Rake::Task["radiant:extensions:vhost:apply_site_scoping"].invoke

  end
  
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    require 'highline/import'
    require 'radiant/extension_migrator'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or
      agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")
      
      # Migrate extensions downward
      Radiant::ExtensionLoader.instance.extensions.each do |ext|
        # The first time you bootstrap you'll always encounter exceptions
        # so be sure to ignore them here.
        begin
          ext.migrator.migrate(0)
        rescue
          puts "An error occurred while migrating the #{ext} extension downward: #{$!}"
        end
      end
      
      # Migrate downward
      ActiveRecord::Migrator.migrate("#{RADIANT_ROOT}/db/migrate/", 0)

      # Migrate upward 
      Rake::Task["db:migrate"].invoke
      
      # Migrate extensions upward
      Radiant::ExtensionLoader.instance.extensions.each do |ext|
        # The first time you bootstrap you'll always encounter exceptions
        # so be sure to ignore them here.
        ext.migrator.migrate
      end

      # Remigrate the extensions to catch any new site scoped extensions added
      Rake::Task["radiant:extensions:vhost:apply_site_scoping"].invoke
      
      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end
end