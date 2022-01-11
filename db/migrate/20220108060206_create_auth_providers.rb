class CreateAuthProviders < ActiveRecord::Migration[6.1]
  def up
    create_table :auth_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end
    add_index :auth_providers, [:user_id, :uid], unique: true
  end

  def down
    remove_index :auth_providers, [:user_id, :uid], unique: true, if_exists: true

    drop_table :auth_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end
  end
end
