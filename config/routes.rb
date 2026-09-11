Rails.application.routes.draw do
  root 'landing#index'
  resources :landing, only: [ :index ]
  get '/explore', to: redirect("#{Rails.application.config.relative_url_root}/browse")

  resource :browse, only: %i[show edit], controller: :browse
  resources :changelog, only: %i[index]
  resource :compare, only: %i[show], controller: :compare
  resources :doc, only: %i[index]
  resources :download, only: [ :new ]
  resource :print, only: %i[show], controller: :print

  get 'doc/ukhpi', to: 'doc#ukhpi', as: 'ukhpi_doc'
  get 'doc/ukhpi-dsd', to: 'doc#ukhpi_dsd'
  get 'doc/ukhpi-user-guide', to: 'doc#ukhpi_user_guide'

  get '/version', to: 'application#version'

  # No catch-all route for unmatched paths: the routing error is rendered as a 404
  # by `config.exceptions_app`, see config/application.rb.
end
