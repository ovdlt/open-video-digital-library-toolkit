class CreateDescriptorsVideos < ActiveRecord::Migration

  def self.up

    create_table :descriptors_videos, :id => false do |t|
      t.column :descriptor_id, :int, :null => false
      t.column :video_id, :int, :null => false
      t.timestamps
    end

    add_index :descriptors_videos, [ :descriptor_id, :video_id ],
              :unique => true
    add_index :descriptors_videos, [ :video_id, :descriptor_id ],
              :unique => true

  end

  def self.down
    drop_table :descriptors_videos
  end
end
