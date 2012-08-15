class AddReplyToPost < ActiveRecord::Migration
  def change
    add_column :posts, :reply_to, :integer, :default => false
  end
end
