class CreateRightsDetails < ActiveRecord::Migration
  def self.up
    create_table :rights_details do |t|
      t.integer  :property_id,                   :null => false
      t.string   :statement,     :limit => 128,  :null => false
      t.string   :license,       :limit => 128,  :null => false
      t.text     :html,                          :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :rights_details
  end
end
