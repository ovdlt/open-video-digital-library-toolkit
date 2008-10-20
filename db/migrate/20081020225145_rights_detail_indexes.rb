class RightsDetailIndexes < ActiveRecord::Migration
  def self.up
    add_index :rights_details, :license, :unique => true
  end

  def self.down
    remove_index :rights_details, :license
  end
end
