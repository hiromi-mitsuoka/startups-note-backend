class ArticlesController < ApplicationController
  before_action :set_article, only: %i[destroy]

  def index
    # page(params[:~~_page]): https://github.com/kaminari/kaminari#changing-the-parameter-name-param_name-for-the-links
    @categories = Category.with_deleted.order(used_articles: "DESC").page(params[:categories_page]).per(40)
    @media = Medium.all
    # redis設定する

    @articles = Article.with_deleted.eager_load(:medium).order(id: :desc).page(params[:articles_page]).per(30)
    # 後々Elasticsearch削除。ransack導入
    # @articles = if search_query.present?
    #               Article.es_search(search_query).records
    #             else
    #               # TODO: ESのarticleにmedia_nameも追加する
    #               # TODO: 検索なしの場合でもESから取得する

    #               # NOTE: Including articles deleted by logical
    #               Article.with_deleted.eager_load(:medium).order(id: :desc)
    #             end
  end

  def destroy
    # https://ccbaxy.xyz/blog/2021/01/31/ruby62/#todonoxue-chu-moshi-zhuang
    if @article.deleted_at.nil?
      if @article.destroy # Logical delete
        respond_to do |format|
          format.html { redirect_to articles_path, notice: "Successfully deleted.", status: :see_other }
        end
      end
    else
      if @article.restore # Restore from logical delete
        respond_to do |format|
          format.html { redirect_to articles_path, notice: "Successfully restored.", status: :see_other }
        end
      end
    end
  end

  private

  def search_query
    @search_query ||= params[:search_query]
  end

  def set_article
    @article = Article.with_deleted.find_by(id: params[:id])
  end

end
