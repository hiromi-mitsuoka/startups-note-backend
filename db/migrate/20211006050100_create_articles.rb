class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.references :medium
      t.string :title
      t.string :url
      t.string :image
      t.date :published
      # TechCrunch用に512バイトに変更
      # t.string :categories, limit: 512

      # To deal with error(Mysql2::Error: Data too long for column 'categories' at row 24)
      t.text :categories

      t.timestamps
    end
  end
end
