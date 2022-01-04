module ArticlesHelper
  def total_articles
    Article.with_deleted.count
  end
end
