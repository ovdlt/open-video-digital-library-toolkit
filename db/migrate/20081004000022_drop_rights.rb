class DropRights < ActiveRecord::Migration
  def self.up
    begin drop_table :rights; rescue; end
  end

  def self.down
  end
end
