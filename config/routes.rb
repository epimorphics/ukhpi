# frozen_string_literal: true

Rails.application.routes.draw do
  root 'landing#index'
  resources :landing, only: [:index]
  get '/explore', to: redirect("#{Rails.application.config.relative_url_root}/browse")
  resources :download, only: [:new]
  resource :browse, only: %i[show edit], controller: :browse

  resource :compare, only: %i[show], controller: :compare
  resource :print, only: %i[show], controller: :print
  resources :changelog, only: %i[index]
  resources :doc, only: %i[index]

  get 'doc/ukhpi', to: 'doc#ukhpi', as: 'ukhpi_doc'
  get 'doc/ukhpi-dsd', to: 'doc#ukhpi_dsd'
  get 'doc/ukhpi-user-guide', to: 'doc#ukhpi_user_guide'
end
