class AddReadToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :read, :boolean, :default => 0
  end
end
