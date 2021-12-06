class Api::V1::CategoriesController < Api::ApplicationController
  def index
    categories = Category.all.order(used_articles: "DESC").limit(30)

    render json: {
      categories: categories
    }, status: :ok
  end
end
