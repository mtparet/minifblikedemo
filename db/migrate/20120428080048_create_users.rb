class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :fb_id
      t.string :access_token
      t.integer :like_id

      t.timestamps
    end
  end
end
