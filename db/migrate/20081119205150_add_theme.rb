class AddTheme < ActiveRecord::Migration
  def self.up
    add_column :libraries, :theme, :string, 
                           :null => false, :default => "default"
  end

  def self.down
    remove_column :libraries, :theme
  end
end
