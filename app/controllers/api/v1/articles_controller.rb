class Api::V1::ArticlesController < Api::ApplicationController
  before_action :set_article, only: %i[show]

  def index
    # TODO: Get from Elasticsearch without search.
    # TODO: redis設定する
    articles = if search_query.present?
                 Article.es_search(search_query).records.page(params[:articles_page]).per(20)
               else
                 Article.all.order(id: :desc).page(params[:articles_page]).per(20)
               end

    render json: {
      articles: articles
    }, status: :ok
  end

  def show
    # TODO: I want to return with Elasticsearch???
    render json: {
      comments: @article.comments
    }
  end

  private

  def search_query
    @search_query ||= params[:search_query]
  end

  def set_article
    @article = Article.find_by(id: params[:id])
  end
end