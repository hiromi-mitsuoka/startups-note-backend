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
          begin
            # To ensure that there are not zero cases of incomplete news.
            article = Article.new(
              medium_id: medium.id,
              title: f.title,
              url: f.url,
              image: f.image,
              published: f.published,
              categories: f.categories,
            )
            articles << article
          rescue => e
            # TODO: logger.errorに変更する
            Rails.logger.error(e.message)
            Rails.logger.error(article&.title) if article.title.present?
          end
        end
      end
      # bulk_insert
      columns = %i[id medium_id title url image published categories]
      Article.import columns, articles
      # Article.delay.import columns, articles
      p "===== Imported #{articles.size} articles ====="
      Rails.logger.info("===== Imported #{articles.size} articles =====")
    rescue => e
      Rails.logger.error(e.message)
    end
    p "===== DONE article:crawl ====="
    Rails.logger.info("===== DONE article:crawl =====")
  end

  # 新しく入る記事のみカテゴリの使用回数をカウントアップ
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
      p "===== Imported #{articles.size} new articles ====="
      Rails.logger.info("===== Imported #{articles.size} new articles =====")

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
      p "===== Imported #{insert_categories.size} new categories ====="
      Rails.logger.info("===== Imported #{insert_categories.size} new categories =====")
    rescue => e
      Rails.logger.error(e.message)
    end
    p "===== DONE article:crawl_and_extract_categories ====="
    Rails.logger.info("===== DONE article:crawl_and_extract_categories =====")
  end


  # ECS Scheduled Tasks
  desc "Get articles and count used_articles of categories"
  task get_articles_count_used_categories: :environment do
    Rake::Task['article:crawl'].invoke # 記事を取得
    Rake::Task['category:extract'].invoke # 重複なくカテゴリーを抽出
    Rake::Task['category:check_used_articles'].invoke # カテゴリーの使用回数を更新
    Rake::Task['category:check_used_articles_with_es'].invoke # ESのヒット数で記事数を更新する（TODO: remove the above command but the rake task needs to be adjusted.）
    p "===== #{Time.now}: DONE article:get_articles_count_used_categories ====="
    Rails.logger.info("===== #{Time.now}: DONE article:get_articles_count_used_categories =====")
  end
end

# 実行コマンド :
# bundle exec rake article:crawl
# bundle exec rake article:crawl_and_extract_categories
# feed URL を取得するサービス : https://berss.com/feed/
