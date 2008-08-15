class CreateVideos < ActiveRecord::Migration
  def self.up

    create_table :videos do |t|
      t.string  :title,    :limit => 50, :null => false
      t.string  :year,     :limit => 4, :null => true
      t.string  :sentence, :limit => 400
      t.string  :filename, :limit => 100, :null => false
      t.integer :size,     :null => false
      t.timestamps
    end

    add_index :videos, :filename, :unique => true

    create_table :video_fulltexts do |t|
      t.integer :video_id, :null => false
      t.string  :title,    :limit => 50, :null => false
      t.string  :year,     :limit => 4, :null => true
      t.string  :sentence, :limit => 400
    end

    execute "alter table video_fulltexts engine = myisam"

    add_index :video_fulltexts, :video_id, :unique => true

    execute "create fulltext index video_fulltexts_index on video_fulltexts " +
            "( title, sentence, year )"

  end

  def self.down
    drop_table :videos
  end
end
