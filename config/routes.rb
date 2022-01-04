Rails.application.routes.draw do
  root "articles#index"
  resources :articles, only: %i[index destroy]
  resources :categories, only: %i[show destroy]

  # 後ほどファイル分割
  namespace :api do
    namespace :v1 do
      resources :articles, only: [:index]
      resources :categories, only: [:index]
    end
  end
end
