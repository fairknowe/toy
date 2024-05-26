# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"
  mount ActionCable.server, at: "/cable"

  mount ShopifyApp::Engine, at: "/api"
  get "/api", to: redirect(path: "/") # Needed because our engine root is /api but that breaks FE routing

  # If you are adding routes outside of the /api path, remember to also add a proxy rule for
  # them in web/frontend/vite.config.js

  post "/api/toy_webhooks/*type", to: "app_webhooks#receive"
  get "/api/current/user", to: "user#current"
  get "/api/products/count", to: "products#count"
  post "/api/products/create", to: "products#create"

  # Any other routes will just render the react app
  match "*path" => "home#index", via: [ :get, :post ]
end
