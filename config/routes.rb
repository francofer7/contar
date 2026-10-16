Rails.application.routes.draw do
  root "dashboard#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "convertidores/:key", to: "converters#show", as: :converter
  get "converter-assets/:filename", to: "converters#asset", as: :converter_asset,
    constraints: { filename: /[a-z0-9.-]+/ }

  namespace :admin do
    resources :users, except: :show
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

end
