class ChangeAnnotationType < ActiveRecord::Migration
  def self.up
    change_column :bookmarks, :annotation, :text, :limit => 800
  end

  def self.down
    change_column :bookmarks, :annotation, :string
  end
end
