class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.integer :user_id,       :null => false
      t.string  :title,         :null => false
      t.text    :description,   :null => true
      t.integer :views,         :null => false, :default => 0
      t.boolean :public, :null => false, :default => false
      t.timestamps
    end

    add_index :collections, :user_id

  end

  def self.down
    drop_table :collections
  end
end
