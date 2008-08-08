class CreateDescriptorTypes < ActiveRecord::Migration
  def self.up
    create_table :descriptor_types do |t|
      t.column :title, :string, :null => false
      t.timestamps
    end

    add_index :descriptor_types, :title, :unique => true

  end

  def self.down
    drop_table :descriptor_types
  end
end
