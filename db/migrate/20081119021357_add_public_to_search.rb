class AddPublicToSearch < ActiveRecord::Migration
  def self.up
    add_column :criteria, :public, :boolean, :null => true
  end

  def self.down
    remove_column :criteria, :public
  end
end
