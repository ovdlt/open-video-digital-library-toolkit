class AddDownlodsToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :last_viewed, :datetime, :null => true
    add_column :videos, :last_downloaded, :datetime, :null => true
    add_column :videos, :downloads, :int, :null => false, :default => 0
  end

  def self.down
    remove_column :videos, :last_viewed
    remove_column :videos, :last_downloaded
    remove_column :videos, :downloads
  end
end
