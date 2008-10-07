
class CreateProperties < ActiveRecord::Migration
  def self.up

    create_table :properties do |t|

      t.integer :video_id,              :null => false

      t.integer :property_type_id,      :null => false

      # there are non-null because otherwise the unique index doesn't
      # enforce uniquness per the SQL standard
      # perhaps not worth it, but ...

      t.date :date_value,               :null => false
      t.string :string_value,           :null => false
      t.integer :integer_value,         :null => false

      t.timestamps

    end

    # used to require uniquiness; not current used for lookup (?)
    add_index :properties, [ :video_id,
                             :property_type_id,
                             :integer_value,
                             :string_value,
                             :date_value ],
              :unique => true, :name => :properties_values
  end

  def self.down
    begin
      drop_table :properties
    rescue Exception; end
  end
end
