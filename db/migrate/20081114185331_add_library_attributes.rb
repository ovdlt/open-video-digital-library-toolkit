class AddLibraryAttributes < ActiveRecord::Migration
  def self.up
    add_column :libraries, :about, :text
    add_column :libraries, :contact, :text
    add_column :libraries, :privacy, :text
    add_column :libraries, :news, :text
    add_column :libraries, :emails, :string
  end

  def self.down
    remove_column :libraries, :emails
    remove_column :libraries, :news
    remove_column :libraries, :privacy
    remove_column :libraries, :contact
    remove_column :libraries, :about
  end
end
