class CreateUsers < ActiveRecord::Migration[6.1]
  def up
    create_table :users do |t|
      t.string :name
      t.string :email, null: false, unique: true
      t.string :uid, null: false, unique: true
      t.index :uid, unique: true

      t.timestamps
    end
  end

  def down
    # https://api.rubyonrails.org/v7.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
    remove_index :users, :uid, if_exists: true

    drop_table :users do |t|
      t.string :name
      t.string :email, null: false, unique: true
      t.string :uid, null: false, unique: true

      t.timestamps
    end
  end
end
