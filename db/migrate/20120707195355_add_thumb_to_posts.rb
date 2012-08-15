class AddThumbToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :user_thumbnail, :string
  end
end
