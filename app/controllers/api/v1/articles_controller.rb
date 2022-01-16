class Api::V1::ArticlesController < Api::ApplicationController
  before_action :set_article, only: %i[show]

  def index
    # TODO: redis設定する
    articles = if search_query.present?
                 Article.es_search(search_query).records
               else
                 Article.es_search_all.records # set to max 100 using size query.
               end

    render json: articles
    # render json: articles, serializer: Api::V1::ArticleSerializer: not move
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