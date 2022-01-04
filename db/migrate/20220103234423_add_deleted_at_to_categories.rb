class AddDeletedAtToCategories < ActiveRecord::Migration[6.1]
  def up
    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at

    # Add deleted_at and then crawl to avoid errors.
    Rake::Task['category:extract'].invoke # 重複なくカテゴリーを抽出
    Rake::Task['category:check_used_articles'].invoke # カテゴリーの使用回数を更新
  end
end
