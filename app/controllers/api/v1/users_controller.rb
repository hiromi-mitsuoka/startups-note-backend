class Api::V1::UsersController < Api::ApplicationController
  def create
    user = User.find_or_initialize_by(uid: user_params[:uid])
    if user.new_record?
      user.update(
        name: user_params[:name],
        email: user_params[:email]
      )
      user.save
      # user.auth_providers.create(
      #   provider: user_params[:provider],
      #   uid: user.uid
      # )
    end
    render json: {
      user: user
    }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :uid, :provider)
  end
end
