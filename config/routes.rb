Rails.application.routes.draw do
  root "articles#index"
  resources :articles

  # 後ほどファイル分割
  namespace :api do
    namespace :v1 do
      resources :articles
    end
  end
end
