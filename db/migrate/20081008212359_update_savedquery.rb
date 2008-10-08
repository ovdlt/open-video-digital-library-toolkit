class UpdateSavedquery < ActiveRecord::Migration
  def self.up
    rename_column :saved_queries, :descriptor_id, :descriptor_value_id
  end

  def self.down
    rename_column :saved_queries, :descriptor_value_id, :descriptor_id
  end
end
