Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: :shared do
    get "up/db" => "db_health#show", as: :db_health_check
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  mount ActionCable.server => "/cable"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  scope module: :ordering do
    root "orders#index"

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

  scope module: :identity do
    resource :profile, only: %i[show update], controller: "profile"
  end

  scope module: :notifications do
    resources :notifications, only: %i[update]
  end

  namespace :payments do
    post "webhooks/:provider/events", to: "payment_webhooks#create", as: :webhook_events
  end
end
