class AddTagToSearch < ActiveRecord::Migration
  def self.up
    add_column :criteria, :tag, :integer, :null => true
  end

  def self.down
    remove_column :criteria, :tag
  end
end
