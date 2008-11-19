class AddPublicToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :public, :boolean, :default => false

    Video.find(:all).each do |video|
      video.public = true
      video.save!
    end

    add_index :videos, [ :public, :id ]

  end

  def self.down
    remove_index :videos, [ :public, :id ]
    remove_column :videos, :public
  end
end
