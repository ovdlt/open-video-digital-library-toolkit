class SwitchColUseridToLogin < ActiveRecord::Migration
  def self.up
    add_column :libraries, :collections_login, :string, :null => false

    update "update libraries,users set collections_login = users.login " +
           "where libraries.collections_user_id = users.id"

    remove_column :libraries, :collections_user_id

  end

  def self.down
    add_column :libraries, :collections_user_id, :integer, :null => false
    
    update "update libraries, users set collections_user_id = users.id " +
           "where libraries.collections_login = users.login"

    remove_column :libraries, :collections_login

  end
end
