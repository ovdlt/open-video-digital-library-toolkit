class CreateVideos < ActiveRecord::Migration
  def self.up

    create_table :videos do |t|
      t.string  :title,         :limit => 50,   :null => false
      t.string  :year,          :limit => 4,    :null => true
      t.string  :sentence,      :limit => 400,  :null => false
      t.text    :abstract,      :limit => 2000, :null => true
      t.string  :rights_holder, :limit => 80,   :null => true
      t.integer :rights_id,                     :null => false
      t.integer :duration,                      :null => true

      t.integer :views,                         :null => false, :default => 0
      t.string  :local_id,                      :null => true
      t.string  :donor,                         :null => true
      t.timestamps
    end

    create_table :video_fulltexts do |t|
      t.integer  :video_id, :null => false
      t.text     :text, :null => false
    end

    execute "alter table video_fulltexts engine = myisam"

    add_index :video_fulltexts, :video_id, :unique => true

    execute "create fulltext index video_fulltexts_index on video_fulltexts " +
            "( text )"

  end

  def self.down
    drop_table :videos
  end
end
