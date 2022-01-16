class AddDeletedAtToCategories < ActiveRecord::Migration[6.1]
  def up
    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at

    Rake::Task['category:extract'].invoke # 重複なくカテゴリーを抽出
    Rake::Task['category:check_used_articles'].invoke # カテゴリーの使用回数を更新
    Rake::Task['category:check_used_articles_with_es'].invoke # ESのヒット数で記事数を更新する（TODO: remove the above command but the rake task needs to be adjusted.）
  end
end
