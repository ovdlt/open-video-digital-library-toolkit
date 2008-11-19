class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :text, :null => false
      t.timestamps
    end
    add_index :tags, :text, :unique => true
  end

  def self.down
    drop_table :tags
  end
end
