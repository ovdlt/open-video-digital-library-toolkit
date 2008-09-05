class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.integer :video_id, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end

    add_index :downloads, [ :video_id, :user_id ], :unique => true
    add_index :downloads, [ :user_id, :video_id ], :unique => true

  end

  def self.down
    drop_table :downloads
  end
end
