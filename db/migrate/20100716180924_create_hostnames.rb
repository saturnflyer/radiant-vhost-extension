class CreateHostnames < ActiveRecord::Migration
  def self.up
    create_table :hostnames, :force => true do |t|
      t.string  :domain, :unique => true
      t.string  :port, :default => 80
      t.integer :site_id
      t.timestamps
    end
    Hostname.reset_column_information
    Site.find_in_batches do |sites|
      sites.each { |site|
        site.hostnames.find_or_create_by_domain(:domain => site.hostname)
      }
    end
  end

  def self.down
    drop_table :hostnames
  end
end
