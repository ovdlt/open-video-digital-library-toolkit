class CreateDescriptorValues < ActiveRecord::Migration
  def self.up
    create_table :descriptor_values do |t|
      t.integer :property_type_id,      :null => false
      t.string  :value,                 :null => false
      t.timestamps
    end

    add_index :descriptor_values,
              [ :property_type_id, :value ],
              :unique => true

  end

  def self.down
    drop_table :descriptor_values
  end
end
