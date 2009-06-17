class CreateImportMaps < ActiveRecord::Migration
  def self.up
    create_table :import_maps do |t|
      t.string :name, :null => false
      t.text :yml, :null => false
      t.timestamps
    end

    add_index :import_maps, :name, :unique => true
  end

  def self.down
    drop_table :import_maps
  end
end
