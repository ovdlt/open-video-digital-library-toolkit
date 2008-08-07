class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.column          :title, :string, :limit => 50, :null => false
      t.column          :subtitle, :string, :limit => 80, :null => true
      t.column          :logo_url, :string, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
