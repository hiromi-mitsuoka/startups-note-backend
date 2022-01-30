class Api::V1::CategoriesController < Api::ApplicationController
  def index
    categories = Category.all.order(used_articles: "DESC").limit(15)

    render json: {
      categories: categories
    }, status: :ok
  end
end
