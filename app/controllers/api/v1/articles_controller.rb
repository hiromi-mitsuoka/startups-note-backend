class Api::V1::ArticlesController < Api::ApplicationController
  def index
    # 後々Elasticsearchで返す
    # redis設定する
    articles = if @search_query.present?
                 Article.es_search(@search_query).records
               else
                 Article.all.order(id: :desc)
               end

    render json: {
      articles: articles
    }, status: :ok
  end

  private

  def search_query
    @search_query ||= params[:search_query]
  end
end