class DropSavedQueries < ActiveRecord::Migration
  def self.up
    drop_table :saved_queries
  end

  def self.down
    create_table :saved_queries do |t|
      t.integer :user_id, :null => false
      t.integer :descriptor_id
      t.string  :query_string
      t.string  :note
      t.timestamps
    end

    add_index :saved_queries, :user_id

  end

end
