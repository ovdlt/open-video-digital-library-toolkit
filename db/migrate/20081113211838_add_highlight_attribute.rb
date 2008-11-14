class AddHighlightAttribute < ActiveRecord::Migration
  def self.up
    add_column :videos, :featured, :boolean, :default => false, :null => false
    add_column :videos, :featured_on, :datetime
    add_column :collections, :featured, :boolean, :default => false, :null => false
    add_column :collections, :featured_on, :datetime

    add_index :videos, [ :featured, :featured_on ]
    add_index :collections, [ :featured, :featured_on ]
  end

  def self.down
    remove_column :collections, :featured_on
    remove_column :collections, :featured
    remove_column :videos, :featured_on
    remove_column :videos, :featured
  end
end
