class Api::V1::CommentsController < Api::ApplicationController
  # def new
  # end

  def create
    user_id = User.find_by!(uid: comment_params[:uid]).id
    comment = Comment.new(comment_params)
    comment.user_id = user_id
    comment.save!
    render json: comment
  end

  # def edit
  # end

  # def update
  # end

  def destroy

  end

  private

  def comment_params
    params.permit(:uid, :article_id, :text)
  end
end
