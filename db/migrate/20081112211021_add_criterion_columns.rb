class AddCriterionColumns < ActiveRecord::Migration
  def self.up
    add_column :criteria, :text, :string, :null => true
    add_column :criteria, :criterion_type, :string, :null => false
    add_column :criteria, :duration, :integer, :null => true
    add_column :criteria, :property_type_id, :integer, :null => true
    add_column :criteria, :integer_value, :integer, :null => true
  end

  def self.down
    remove_column :criteria, :integer_value
    remove_column :criteria, :property_type_id
    remove_column :criteria, :duration
    remove_column :criteria, :criterion_type
    remove_column :criteria, :text
  end
end
