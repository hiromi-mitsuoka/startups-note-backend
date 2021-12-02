class AddArticlesAndCategoriesToDb < ActiveRecord::Migration[6.1]
  def up
    # 環境構築時のニュース取得、既に存在する記事は削除はされない
    Rake::Task['article:crawl'].invoke # 記事を取得
    Rake::Task['category:extract'].invoke # 重複なくカテゴリーを抽出
    Rake::Task['category:check_used_articles'].invoke # カテゴリーの使用回数を更新
  end

  def down
  end
end
