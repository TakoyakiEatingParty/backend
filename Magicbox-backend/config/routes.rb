Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # 認証関連のルーティング
  get  '/auth/github', to: 'session#github_auth'
  get  '/auth/github/callback', to: 'session#github_callback'
  delete '/logout', to: 'session#destroy'
  #　api関連のルーティング
  namespace :api do
    namespace :v1 do
      resource :current_user , only: [:show], controller: :current_user
    end
  end
end
