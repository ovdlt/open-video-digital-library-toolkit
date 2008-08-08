class CreateDescriptorValues < ActiveRecord::Migration
  def self.up
    create_table :descriptor_values do |t|
      t.column :descriptor_type_id, :int, :null => false
      t.column :text, :string, :null => false
      t.timestamps
    end

    add_index :descriptor_values,
              [ :descriptor_type_id, :text ],
              :unique => true

  end

  def self.down
    drop_table :descriptor_values
  end
end
