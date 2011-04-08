class AddHostTypeToHostname < ActiveRecord::Migration
  def self.up
    add_column :hostnames, :host_type_id, :integer
  end

  def self.down
    remove_column :hostnames, :host_type
  end
end
