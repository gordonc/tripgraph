require 'sidekiq/web'

Tripgraph::Application.routes.draw do
  resources :trips do
    collection do 
      get 'search'
    end
  end
  resources :places do
    collection do 
      get 'search'
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end
