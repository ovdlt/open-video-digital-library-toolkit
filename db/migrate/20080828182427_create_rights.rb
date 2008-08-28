class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.string          :statement,     :limit => 128,  :null => false
      t.string          :license,       :limit => 128,  :null => false
      t.text            :html,                          :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :rights
  end
end
