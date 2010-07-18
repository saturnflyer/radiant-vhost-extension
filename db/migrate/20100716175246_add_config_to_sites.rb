class AddConfigToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :config, :text
    Site.reset_column_information
    Site.find_in_batches do |sites|
      sites.each do |site|
        site.title = site.hostname
        site.save
      end
    end
  end

  def self.down
    remove_column :sites, :config
  end
end
