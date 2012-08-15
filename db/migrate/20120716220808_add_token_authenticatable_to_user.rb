class AddTokenAuthenticatableToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :token_authenticatable, :string, :unique => true
  end
  def self.down
    remove_column :users, :token_authenticatable
  end
end