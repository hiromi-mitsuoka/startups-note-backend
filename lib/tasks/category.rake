namespace :category do
  # adhoc : 存在する記事全てから、重複なくカテゴリーを抽出して作成
  desc "Extract categories from all articles"
  task extract: :environment do
    # 必要なカラムだけ取得
    articles = Article.select(:id, :categories)
    # tmpのみの変数名でなければ問題ないか？
    tmp_categories = []
    insert_categories = []

    begin
      articles.each do |article|
        # ? : 最短一致
        article.categories.scan(/"(.+?)\"/).each do |category|
          tmp_categories << category[0]
        end
      end
      tmp_categories.uniq!

      tmp_categories.each do |category|
        next if Category.find_by(name: category) # 既にDBに存在する場合はスキップ

        insert_category = Category.new(
          name: category,
          used_query: 0,
          used_articles: 1,
        )
        insert_categories << insert_category
      end

      columns = %i[id name used_query used_articles]
      Category.import columns, insert_categories
      p "===== Imported #{insert_categories.size} categories ====="
      Rails.logger.info("===== Imported #{insert_categories.size} categories =====")
    rescue => e
      p "===== Error Imported categories ====="
      Rails.logger.error(e.message)
    end
    p "===== DONE category:extract ====="
    Rails.logger.info("===== DONE category:extract =====")
  end

  # TODO: 月1のメンテナンスとかでカテゴリの使用回数のチェックを行うscheduleの作成

  # 既存記事を全件チェックし、カテゴリの使用回数を更新する
  desc "Check used_articles count from existed articles"
  task check_used_articles: :environment do
    articles = Article.select(:id, :categories)
    categories = []

    begin
      articles.each do |article|
        article.categories.scan(/"(.+?)\"/).each do |category|
          # 重複除かない
          categories << category[0]
        end
      end

      ActiveRecord::Base.transaction do
        # 既存のused_articles数をリセットする
        Category.all.each do |category|
          category.used_articles = 0
          category.save
        end

        categories.each do |category|
          existing_category = Category.find_by(name: category)
          existing_category.used_articles += 1
          existing_category.save
          # p "#{category}: #{existing_category.used_articles}"
        end
      end
    rescue => e
      Rails.logger.error(e.message)
    end
    p "===== DONE category:check_used_articles ====="
    Rails.logger.info("===== DONE category:check_used_articles =====")
  end

  # Categoriesテーブルに存在するカテゴリーでESに検索をかけ、そのcountをused_articlesに保存する
  desc "Check used_articles count with Elasticsearch"
  task check_used_articles_with_es: :environment do
    ActiveRecord::Base.transaction do
      # 既存のused_articles数をリセットする
      Category.all.each do |category|
        category.used_articles = Article.es_search(category.name).to_a.count
        category.save
      end
    rescue => e
      Rails.logger.error(e.message)
    end
    p "===== DONE category:check_used_articles_with_es ====="
    Rails.logger.info("===== DONE category:check_used_articles_with_es =====")
  end
end


# 実行コマンド :
# bundle exec rake category:extract
# bundle exec rake category:check_used_articles
