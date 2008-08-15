class CreateDescriptorTypes < ActiveRecord::Migration
  def self.up
    create_table :descriptor_types do |t|
      t.column :title, :string, :null => false
      t.column :priority, :int
      t.timestamps
    end

    add_index :descriptor_types, :title, :unique => true
    add_index :descriptor_types, [ :priority, :title ]

  end

  def self.down
    drop_table :descriptor_types
  end
end
