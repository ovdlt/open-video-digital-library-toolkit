
class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|

      t.integer :video_id, :null => false

      t.integer :property_type_id, :null => false

      t.date :date_value, :null => true
      t.string :string_value, :null => true
      t.integer :integer_value, :null => true

      t.timestamps

    end
  end

  def self.down
    drop_table :properties
  end
end
