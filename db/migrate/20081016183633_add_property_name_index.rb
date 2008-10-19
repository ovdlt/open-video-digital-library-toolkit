class AddPropertyNameIndex < ActiveRecord::Migration
  def self.up
    add_index :property_types, :name, :unique => true
  end

  def self.down
  end
end
