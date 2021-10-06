# 名前空間 : グループ分けに利用
namespace :article do
  # タスクの説明
  desc ""
  # タスク名（処理名）
  task crawl: :environment do
    # 文字列にしないと、「/」が正規表現と認識される
    xml = HTTParty.get("https://jp.techcrunch.com/feed/").body
    feed = Feedjira.parse(xml)
    articles = []
    feed.entries.each do |f|
      # p article.title
      # p article.url
      # p article.published
      # p article.categories
      article = Article.new(
        title: f.title,
        url: f.url,
        published: f.published,
        categories: f.categories
      )
      articles << article
    end
    # bulk_insert
    columns = %i[id title url published categories]
    Article.import columns, articles, on_duplicate_key_update: %i[title]
  end
end

# 実行コマンド : bundle exec rake article:crawl
