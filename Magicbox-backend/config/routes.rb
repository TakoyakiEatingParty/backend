Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get  '/auth/github/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  namespace :api do
    namespace :v1 do
      resource :current_user , only: [:show], controller: :current_user
    end
  end
end
