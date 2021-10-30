Rails.application.routes.draw do
  get 'categories/index'
  root "articles#index"
  resources :articles, only: [:index]
  resources :categories, only: [:index]

  # 後ほどファイル分割
  namespace :api do
    namespace :v1 do
      resources :articles, only: [:index]
    end
  end
end
