class CreatePriorities < ActiveRecord::Migration
  def self.up
    create_table :priorities do |t|
      t.integer  :object_id, :null => false
      t.integer  :priority, :null => false
      t.timestamps
    end

    add_index :priorities, :object_id, :unique => true

  end

  def self.down
    drop_table :priorities
  end
end
