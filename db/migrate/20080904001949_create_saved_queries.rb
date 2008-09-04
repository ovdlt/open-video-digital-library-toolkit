class CreateSavedQueries < ActiveRecord::Migration
  def self.up
    create_table :saved_queries do |t|
      t.integer :user_id, :null => false
      t.integer :descriptor_id
      t.string  :query_string
      t.string  :note
      t.timestamps
    end

    add_index :saved_queries, :user_id

  end

  def self.down
    drop_table :saved_queries
  end
end
