class CreateComments < ActiveRecord::Migration[6.1]
  def up
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.string :uid, null: false
      t.text :text, null: false

      t.timestamps
    end
    # Not unique since multiple submissions are possible.
    add_index :comments, [:user_id, :article_id]
  end

  def down
    remove_index :comments, [:user_id, :article_id], if_exists: true

    drop_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.text :text, null: false

      t.timestamps
    end
  end
end
