require 'sidekiq/web'
# mount Sidekiq::Web => '/sidekiq'

Rails.application.routes.draw do
  resources :contacts
  resources :imports do
    collection { post :import }
  end

  devise_for :users
  root 'pages#home'
  # 

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
