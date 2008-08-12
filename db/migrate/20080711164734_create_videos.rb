class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string  :title,    :limit => 50, :null => false
      t.string  :sentence, :limit => 400
      t.string  :filename, :limit => 100, :null => false
      t.integer :size,     :null => false
      t.timestamps
    end

    add_index :videos, :filename, :unique => true

  end

  def self.down
    drop_table :videos
  end
end
