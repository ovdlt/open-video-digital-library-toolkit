class AddPosterPath < ActiveRecord::Migration
  def self.up
    add_column :videos, :poster_path, :string, :null => true
  end

  def self.down
    remove_column :videos, :poster_path
  end
end
