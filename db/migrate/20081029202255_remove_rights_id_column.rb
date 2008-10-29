class RemoveRightsIdColumn < ActiveRecord::Migration
  def self.up
    remove_column :videos, :rights_id
  end

  def self.down
    add_column :videos, :rights_id, :integer
  end
end
