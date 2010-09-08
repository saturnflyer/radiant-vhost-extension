class AddDefaultSite < ActiveRecord::Migration

  def self.up
    if Site.count == 0
      site = Site.create!(:title => 'Default')
      hostname = Hostname.find_or_create_by_domain('*')
      site.hostnames << hostname
      if ActiveRecord::Base.connection.table_exists?('pages')
        Page.current_site = nil
        Page.all.each do |record|
          record.update_attribute(:site_id, site.id)
        end
      end
      if ActiveRecord::Base.connection.table_exists?('layouts')
        Layout.current_site = nil
        Layout.all.each do |record|
          record.update_attribute(:site_id, site.id)
        end
      end
      if ActiveRecord::Base.connection.table_exists?('snippets')
        Snippet.current_site = nil
        Snippet.find_in_batches do |group|
          group.each do |record|
            record.update_attribute(:site_id, site.id)
          end
        end
      end
      site_admin = User.find_by_login('admin') || User.first
      site_admin.update_attribute(:site_admin, true)
    end
  end
end
 