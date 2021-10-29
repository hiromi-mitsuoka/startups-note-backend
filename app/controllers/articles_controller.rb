class ArticlesController < ApplicationController
  def index
    # 後々Elasticsearchで返す
    # redis設定する
    @articles = if search_query.present?
                  Article.es_search(search_query).records
                else
                  Article.all.order(id: :desc)
                end
    # articles = Article.all.order(id: :desc)
  end

  # def destroy
    # 論理削除追加済み
    # https://bagelee.com/programming/ruby-on-rails/using_rails_paranoia/
  # end

  private

  def search_query
    @search_query ||= params[:search_query]
  end

end
