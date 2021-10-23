class Api::V1::ArticlesController < Api::ApplicationController
  def index
    # 後々Elasticsearchで返す
    # redis設定する
    articles = Article.all.order(id: :desc)

    render json: {
      articles: articles
    }, status: :ok
  end
end