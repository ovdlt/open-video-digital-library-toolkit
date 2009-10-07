class AddPasswordResetCode < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_code, :string
  end

  def self.down
    remove_columns :users, :password_reset_code
  end
end
