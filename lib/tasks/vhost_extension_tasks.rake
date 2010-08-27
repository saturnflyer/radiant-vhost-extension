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
      
      desc "Copies public assets of the Vhost to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from VhostExtension"
        Dir[VhostExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(VhostExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
        unless VhostExtension.root.starts_with? RAILS_ROOT # don't need to copy vendored tasks
          puts "Copying rake tasks from VhostExtension"
          local_tasks_path = File.join(RAILS_ROOT, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join VhostExtension.root, %w(lib tasks *.{rb,rake})].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end  
      
      desc "Syncs all available translations for this ext to the English ext master"
      task :sync => :environment do
        # The main translation root, basically where English is kept
        language_root = VhostExtension.root + "/config/locales"
        words = TranslationSupport.get_translation_keys(language_root)
        
        Dir["#{language_root}/*.yml"].each do |filename|
          next if filename.match('_available_tags')
          basename = File.basename(filename, '.yml')
          puts "Syncing #{basename}"
          (comments, other) = TranslationSupport.read_file(filename, basename)
          words.each { |k,v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
          other.delete_if { |k,v| !words[k] }         # Remove if not defined in en.yml
          TranslationSupport.write_file(filename, basename, comments, other)
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
      task :destroy_site_scoping => :environment do
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