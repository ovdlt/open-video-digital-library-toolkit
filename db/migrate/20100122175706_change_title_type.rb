class ChangeTitleType < ActiveRecord::Migration
  def self.up
    change_column :videos, :title, :text, :limit => 100, :null => false
  end

  def self.down
    change_column :videos, :title, :text, :limit => 50, :null => false
  end
end
