class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :in_url
      t.text :out_url
      t.integer :http_status, :default => 301 #default to 301

      t.timestamps
    end

    add_index :links, :in_url
  end
end
