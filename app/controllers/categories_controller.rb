class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show destroy]

  def show
  end

  def destroy
    if @category.deleted_at.nil?
      if @category.destroy # Logical delete
        respond_to do |format|
          format.html { redirect_to articles_path, notice: "Successfully deleted.", status: :see_other }
        end
      end
    else
      if @category.restore # Restore from logical delete
        respond_to do |format|
          format.html { redirect_to articles_path, notice: "Successfully restored.", status: :see_other }
        end
      end
    end
  end

  private

  def set_category
    @category = Category.with_deleted.find_by(id: params[:id])
  end
end
