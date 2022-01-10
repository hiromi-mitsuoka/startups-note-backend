Rails.application.routes.draw do
  root "articles#index"
  resources :articles, only: %i[index destroy]
  resources :categories, only: %i[show destroy]

  # 後ほどファイル分割
  namespace :api do
    namespace :v1 do
      resources :articles, only: %i[index show]
      resources :categories, only: [:index]
      resources :users, only: [:create]
      resources :comments, only: %i[create destroy]
    end
  end
end
