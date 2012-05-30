class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.string :name
      t.string :url
      t.string :image_url
      t.string :provider_id
      t.timestamps
    end

    add_index :authentications, [ :provider, :uid ]
    add_index :authentications, :user_id
  end

  def self.down
    drop_table :authentications
  end
end
