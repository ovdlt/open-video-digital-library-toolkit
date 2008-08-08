class CreateDescriptors < ActiveRecord::Migration
  def self.up
    create_table :descriptors do |t|
      t.column :descriptor_type_id, :int, :null => false
      t.column :text, :string, :null => false
      t.timestamps
    end

    add_index :descriptors,
              [ :descriptor_type_id, :text ],
              :unique => true

  end

  def self.down
    drop_table :descriptors
  end
end
