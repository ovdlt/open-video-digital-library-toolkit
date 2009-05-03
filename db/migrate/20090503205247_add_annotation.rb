class AddAnnotation < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :annotation, :string
  end

  def self.down
    remove_column :bookmarks, :annotation
  end
end
