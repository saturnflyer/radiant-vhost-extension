class CreateHostTypes < ActiveRecord::Migration
  def self.up
    create_table :host_types do |t|
      t.string :host_type
      t.boolean :unique

      t.timestamps
    end
  end

  def self.down
    drop_table :host_types
  end
end
