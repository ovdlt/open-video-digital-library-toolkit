class FixRightsDetailColumnName < ActiveRecord::Migration
  def self.up
    rename_column :rights_details, :property_id, :property_type_id
  end

  def self.down
    rename_column :rights_details, :property_type_id, :property_id
  end
end
