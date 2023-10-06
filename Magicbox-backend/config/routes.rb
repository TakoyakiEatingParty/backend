Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get  '/auth/github', to: 'authentication#github_redirect'
  get  '/auth/github/callback', to: 'authentication#github_auth'
  delete '/logout', to: 'sessions#destroy'
  namespace :api do
    namespace :v1 do
      resource :current_user , only: [:show], controller: :current_user
    end
  end
end
