class CreatePermissions < ActiveRecord::Migration

  class RolesUsers < ActiveRecord::Base
  end

  def self.up
    create_table :permissions do |t|
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false
      t.timestamps
    end

    add_index :permissions, [ :user_id, :role_id ],
              :unique => true

    begin
      ( RolesUsers.find :all ).each do |ur|
        if !Permission.find_by_user_id_and_role_id ur.user_id, ur.role_id
          Permission.create! :user_id => ur.user_id, :role_id => ur.role_id
        end
      end
    rescue
      down
      raise
    end

  end

  def self.down
    drop_table :permissions
  end
end
