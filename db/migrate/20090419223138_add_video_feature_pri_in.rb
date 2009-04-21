class AddVideoFeaturePriIn < ActiveRecord::Migration
  def self.up
    add_index :videos, :featured_priority
    add_index :collections, :featured_priority
  end

  def self.down
    remove_index :videos, :featured_priority
    remove_index :collections, :featured_priority
  end
end
