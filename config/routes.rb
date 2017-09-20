# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsClientLogger::Engine, at: 'logger'
  root 'landing#index'
  resources :landing, only: [:index]
  get '/explore', to: 'exploration#index'
  resources :exploration, only: [:new]
  resources :download, only: [:new]
  resource :browse, only: %i[show edit], controller: :browse
end
