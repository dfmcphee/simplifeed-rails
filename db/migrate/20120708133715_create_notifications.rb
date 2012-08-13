class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.text :message
      t.string :bootstrap_class

      t.timestamps
    end
  end
end