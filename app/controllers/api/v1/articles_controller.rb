class Api::V1::ArticlesController < Api::ApplicationController
  def index
    articles = Article.all.order(id: :desc)

    render json: {
      articles: articles
    }, status: :ok
  end
end