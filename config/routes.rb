Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "up/db" => "db_health#show", as: :db_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  mount ActionCable.server => "/cable"
  root "orders#index"
  resource :profile, only: %i[show update], controller: "profile"

  resources :notifications, only: %i[update]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  namespace :payments do
    post "webhooks/:provider/events", to: "adapters/inbound/webhooks/payment_webhooks#create", as: :webhook_events
  end

  resources :orders, only: %i[index show new edit update] do
    member do
      patch :accept
      patch :cancel
      patch :complete
      patch :reopen
      patch :request_refund
      patch :approve_refund_request
      patch :reject_refund_request
      post :simulate_payment_webhook
    end

    resources :comments, only: :create, controller: "comments"
  end
end
