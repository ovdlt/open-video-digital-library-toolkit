class CreatePropertyTypes < ActiveRecord::Migration
  def self.up
    create_table :property_types do |t|
      t.integer :property_class_id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :property_types
  end
end
