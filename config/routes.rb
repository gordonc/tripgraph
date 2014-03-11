require 'sidekiq/web'

Tripgraph::Application.routes.draw do
  get '/search', to: 'search#index'
  resources :trips
  resources :places
  mount Sidekiq::Web => '/sidekiq'
end
