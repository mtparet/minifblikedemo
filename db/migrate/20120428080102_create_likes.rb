class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :name
      t.string :category
      t.integer :fb_id
      t.integer :user_id

      t.timestamps
    end
  end
end
