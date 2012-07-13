class AddTargetToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :target_id, :integer
    add_column :notifications, :target_type, :string
  end
end
