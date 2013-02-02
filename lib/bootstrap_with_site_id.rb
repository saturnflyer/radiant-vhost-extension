module BootstrapWithSiteId
  def load_database_template_with_site_id(filename)
    template = nil
    if filename
      name = find_template_in_path(filename)
      unless name
        announce "Invalid template name: #{filename}"
        filename = nil
      else
        template = load_template_file(name)
      end
    end
    unless filename
      templates = find_and_load_templates("#{RAILS_ROOT}/vendor/extensions/vhost/db/templates/*.yml")
      templates.concat find_and_load_templates("#{RADIANT_ROOT}/config/extensions/vhost/db/templates/*.yml")
      templates.concat find_and_load_templates("#{RAILS_ROOT}/db/templates/*.yml") if RADIANT_ROOT != RAILS_ROOT
      choose do |menu|
        menu.header = "\nSelect a database template"
        menu.prompt = "[1-#{templates.size}]: "
        menu.select_by = :index
        templates.each { |t| menu.choice(t['name']) { template = t } }
      end
    end
    # If there are sites defined create them first as there are many to many
    # relationships from users to sites that need to be created and will fail
    # if the site isn't created first.
    if !template['records']['Sites'].nil?
      site_template = {}
      site_template['records'] = {}
      site_template['records']['Sites'] = template['records']['Sites']
      create_records(site_template)
      template['records'].delete('Sites')
    end
    create_records(template)

    User.first.update_attributes(:site_admin => true)
  end

  def find_template_in_path_with_site_id(filename)
        [
          filename,
          "#{RAILS_ROOT}/vendor/extensions/vhost/db/templates/#{filename}",
          "#{RADIANT_ROOT}/config/extensions/vhost/db/templates/#{filename}",
          "#{RADIANT_ROOT}/#{filename}",
          "#{RADIANT_ROOT}/db/templates/#{filename}",
          "#{RAILS_ROOT}/#{filename}",
          "#{RAILS_ROOT}/db/templates/#{filename}",
          "#{Dir.pwd}/#{filename}",
          "#{Dir.pwd}/db/templates/#{filename}",
        ].find { |name| File.file?(name) }
  end
end
