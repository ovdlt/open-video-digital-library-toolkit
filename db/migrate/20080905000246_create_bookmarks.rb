class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.integer :video_id, :null => false
      t.integer :collection_id, :null => false
      t.timestamps
    end
    
    add_index :bookmarks, [ :video_id, :collection_id ], :unique => true
    add_index :bookmarks, [ :collection_id, :video_id ], :unique => true

  end

  def self.down
    drop_table :bookmarks
  end
end
