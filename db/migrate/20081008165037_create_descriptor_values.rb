class CreateDescriptorValues < ActiveRecord::Migration
  def self.up
    create_table :descriptor_values do |t|
      t.integer :property_type_id,      :null => false
      t.string  :text,                  :null => false
      t.integer :priority,              :null => false, :default => 999
      t.timestamps
    end

    add_index :descriptor_values, [ :property_type_id, :text ], :unique => true

    add_index :descriptor_values, [ :property_type_id, :priority ]

  end

  def self.down
    drop_table :descriptor_values
  end
end

