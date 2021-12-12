class AddArticlesAndCategoriesToDb < ActiveRecord::Migration[6.1]
  def up
    # 初回の環境構築（既に存在するデータはリセットされない）
    # seed.rbから拝借
    if Medium.count == 0
      Medium.create!(
        name: "Crunchbase news",
        url: "https://news.crunchbase.com",
        rss: "https://news.crunchbase.com/feed/",
      )
      Medium.create!(
        name: "CORAL",
        url: "https://coralcap.co/?lang=en",
        rss: "https://coralcap.co/feed/?lang=en",
      )
      Medium.create!(
        name: "TechCrunch",
        url: "https://techcrunch.com/",
        rss: "https://techcrunch.com/feed/",
      )
    end
    Rake::Task['article:crawl'].invoke # 記事を取得
    Rake::Task['category:extract'].invoke # 重複なくカテゴリーを抽出
    Rake::Task['category:check_used_articles'].invoke # カテゴリーの使用回数を更新
  end

  def down
    #  rollbackではなく、db:migrate:resetで対応する
  end
end
