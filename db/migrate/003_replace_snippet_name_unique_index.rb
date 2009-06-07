class ReplaceSnippetNameUniqueIndex < ActiveRecord::Migration
  def self.up
    remove_index :snippets, :name => :name
  end
  
  
  def self.down
    add_index "snippets", ["name"], :name => "name", :unique => true
  end
end