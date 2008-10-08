class CreatePropertyTypes < ActiveRecord::Migration
  def self.up
    create_table :property_types do |t|
      t.integer :property_class_id,     :null => false
      t.string  :name,                  :null => false
      t.integer :priority,              :null => false, :default => 999
      t.timestamps
    end

    add_index :property_types, [ :property_class_id, :priority ]
    add_index :property_types, :priority

  end

  def self.down
    drop_table :property_types
  end
end
