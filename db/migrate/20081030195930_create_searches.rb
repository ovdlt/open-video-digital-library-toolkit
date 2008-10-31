class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.integer :user_id,       :null => false
      t.string  :title,         :null => true
      t.text    :description,   :null => true
      t.integer :views,         :null => false, :default => 0
      t.boolean :public,        :null => false, :default => false

      # could be a criterion eventually, but easier to do right now?
      t.string  :text,          :null => true
      t.integer :duration,      :null => true

      t.timestamps
    end

    add_index :searches, :user_id
    add_index :searches, [ :public, :user_id ]

  end

  def self.down
    drop_table :searches
  end
end
