class CreateMedia < ActiveRecord::Migration[6.1]
  def change
    create_table :media do |t|
      t.string :name
      t.string :url
      t.string :rss

      t.timestamps
    end
  end
end
