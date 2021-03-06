require 'sidekiq/web'

Tripgraph::Application.routes.draw do
  get "maps/index"
  root "maps#index"

  get '/search', to: 'search#index'

  mount Sidekiq::Web => '/sidekiq'
end
