class CreateCriteria < ActiveRecord::Migration
  def self.up
    create_table :criteria do |t|
      t.integer         :search_id,       :null => false
      t.timestamps
    end

    add_index :criteria, :search_id

  end

  def self.down
    drop_table :criteria
  end
end
