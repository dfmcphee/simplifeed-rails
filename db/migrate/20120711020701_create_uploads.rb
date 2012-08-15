class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_update_at

      t.timestamps
    end
  end
end
