class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, unique: true
      t.integer :used_query, null: false, default: 0
      t.integer :used_articles, null: false, default: 1

      t.timestamps
    end
  end
end
