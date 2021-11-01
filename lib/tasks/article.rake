# 名前空間 : グループ分けに利用
namespace :article do
  # タスクの説明
  desc ""
  # タスク名（処理名）
  task crawl: :environment do
    articles = []

    # 現状、エラーを検知できていないため、後ほど対応
    # medium_id: medium.id を記述しないと、記事登録されない&エラーにならない
    begin
      Medium.all.each do |medium|
        xml = HTTParty.get(medium.rss).body
        feed = Feedjira.parse(xml)
        feed.entries.each do |f|
          # 重複している記事はスキップ
          same_article = Article.find_by(title: f.title)
          next if same_article.present?

          # delayed_jobを使用するためには、idが入力されている必要があるため代入 ⇨ 上手くいかず断念
          # article_id += 1

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
      columns = %i[id medium_id title url image published categories]
      Article.import columns, articles
      # Article.delay.import columns, articles
      p "Imported #{articles.size} articles"
    rescue => e
      p e.message
    end
    p "DONE"
  end

  task crawl_and_extract_categories: :environment do
    articles = []

    begin
      Medium.all.each do |medium|
        xml = HTTParty.get(medium.rss).body
        feed = Feedjira.parse(xml)
        feed.entries.each do |f|
          # 重複している記事はスキップ
          same_article = Article.find_by(title: f.title)
          next if same_article.present?

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
      columns = %i[id medium_id title url image published categories]
      Article.import columns, articles
      p "Imported #{articles.size} new articles"

      # categories
      tmp_categories = []
      insert_categories = []

      # TODO: ここの処理を軽くしたい
      articles.each do |article|
        article.categories.scan(/"(.+?)\"/).each do |category|
          tmp_categories << category[0]
        end
      end

      # このタスクでは、使用されている回数を保存したいため、uniqにしない
      # tmp_categories.uniq!

      ActiveRecord::Base.transaction do
        tmp_categories.each do |category|
          existing_category = Category.find_by(name: category)
          if existing_category
            existing_category.used_articles += 1
            existing_category.save
          else
            insert_category = Category.new(
              name: category,
              used_query: 0,
              used_articles: 1,
            )
            insert_categories << insert_category
          end
        end
      end

      # bulk_insert
      columns = %i[id name used_query used_articles]
      Category.import columns, insert_categories
      p "Imported #{insert_categories.size} new categories"
    rescue => e
      p e.message
    end
    p "DONE"
  end
end

# 実行コマンド :
# bundle exec rake article:crawl
# bundle exec rake article:crawl_and_extract_categories
# feed URL を取得するサービス : https://berss.com/feed/
