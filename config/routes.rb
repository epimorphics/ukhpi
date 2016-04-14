Rails.application.routes.draw do
  root "landing#index"
  resources :landing, only: [:index]
  get "/explore", to: "exploration#index"
end
