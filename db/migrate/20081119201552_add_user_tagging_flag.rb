class AddUserTaggingFlag < ActiveRecord::Migration
  def self.up
    add_column :libraries, :user_tagging_enabled, :boolean, 
                           :null => false, :default => true
  end

  def self.down
    remove_column :libraries, :user_tagging_enabled
  end
end
