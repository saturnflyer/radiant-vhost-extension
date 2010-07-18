class RemoveSiteHostnameField < ActiveRecord::Migration
  def self.up
    remove_column :sites, :hostname
  end

  def self.down
    add_column :sites, :hostname, :string
    Site.reset_column_information
    Site.find_in_batches do |sites|
      sites.each do |site|
        site.hostname = site.hostnames.first.domain
        site.save
      end
    end
  end
end
