# 名前空間 : グループ分けに利用
namespace :article do
  # タスクの説明
  desc ""
  # タスク名（処理名）
  task crawl: :environment do
    # 文字列にしないと、「/」が正規表現と認識される
    # xml = HTTParty.get("https://news.crunchbase.com/feed/").body
    # feed = Feedjira.parse(xml)

    articles = []
    # 現状、エラーを検知できていないため、後ほど対応
    # medium_id: medium.id を記述しないと、記事登録されない&エラーにならない
    begin
      Medium.all.each do |medium|
        xml = HTTParty.get(medium.url).body
        feed = Feedjira.parse(xml)
        feed.entries.each do |f|
          # 重複している記事はスキップ
          same_article = Article.find_by(title: f.title)
          next if same_article.present?

          # 記事によっては、タグの名前が変わる可能性あり
          # NOTE: techcrunchとnews.crunchbaseは変更する必要なかった。
          article = Article.new(
            medium_id: medium.id,
            title: f.title,
            url: f.url,
            image: f.image,
            published: f.published,
            categories: f.categories,
          )
          articles << article
        end
      end
      # bulk_insert
      # columns = %i[id title url published categories]
      Article.import articles
    rescue => e
      p e.message
    end
  end
  p "DONE"
end

# 実行コマンド : bundle exec rake article:crawl
# feed URL を取得するサービス : https://berss.com/feed/
