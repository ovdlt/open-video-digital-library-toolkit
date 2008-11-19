class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.integer :video_id, :null => false
      t.integer :tag_id, :null => false
      t.timestamps
    end
    add_index :taggings, [ :video_id, :tag_id ], :unique => true
    add_index :taggings, [ :tag_id, :video_id ], :unique => true
  end

  def self.down
    drop_table :taggings
  end
end
