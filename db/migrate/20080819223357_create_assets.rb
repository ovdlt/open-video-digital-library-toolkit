class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :video_id, :null => false
      t.string  :uri, :limit => 100, :null => false
      t.integer :size,     :null => false
      t.integer :format_id
      t.timestamps
    end

    add_index :assets, :uri, :unique => true
  
  end

  def self.down
    drop_table :assets
  end
end
