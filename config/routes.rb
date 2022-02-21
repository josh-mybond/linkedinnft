Rails.application.routes.draw do
  resources :nfts
  resources :customers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "customers#index"
  get '/all_customers', to: 'customers#all_customers'
  post 'webhook', to: "indices#webhook"
end
