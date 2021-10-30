namespace :category do
  # 運用していく上では、記事取得時にやるべきなため、このファイルはadhocにすべき？
  desc "Extract category from articles"
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
        insert_category = Category.new(
          name: category,
          used_query: 0,
          used_articles: 1,
        )
        insert_categories << insert_category
      end

      columns = %i[id name used_query used_articles]
      Category.import columns, insert_categories
      p "Imported #{insert_categories.size} records"
    rescue => e
      p e.message
    end
    p "DONE"
  end
end
