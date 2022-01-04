module CategoriesHelper
  def total_categories
    Category.with_deleted.count
  end
end
