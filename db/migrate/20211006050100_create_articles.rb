class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.references :medium
      t.string :title
      t.string :url
      t.string :image
      t.date :published
      t.string :categories

      t.timestamps
    end
  end
end
