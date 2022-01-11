class Api::V1::CommentsController < Api::ApplicationController
  before_action :set_comment, only: %i[destroy]

  # def new
  # end

  def create
    user_id = User.find_by!(uid: comment_params[:uid]).id
    comment = Comment.new(comment_params)
    # Since user_id cannot be posted from the frontend side, it is handled on the backend side.
    comment.user_id = user_id
    comment.save!
    render json: comment
  end

  # def edit
  # end

  # def update
  # end

  def destroy
    if @comment.destroy
      render json: nil
    end
  end

  private

  def set_comment
    @comment = Comment.find_by(id: params[:id])
  end

  def comment_params
    params.permit(:uid, :article_id, :text)
  end
end
