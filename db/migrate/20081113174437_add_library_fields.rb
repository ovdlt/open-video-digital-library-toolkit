class AddLibraryFields < ActiveRecord::Migration
  def self.up
    add_column :libraries, :copyright, :string
    add_column :libraries, :org_link, :string
  end

  def self.down
    remove_column :libraries, :org_link
    remove_column :libraries, :copyright
  end
end
