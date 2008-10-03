class CreatePropertyClasses < ActiveRecord::Migration
  def self.up
    create_table :property_classes do |t|
      t.string :name, :null => false
      t.boolean :multivalued, :null => false
      t.boolean :optional, :null => false
      t.string :range, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :property_classes
  end
end
