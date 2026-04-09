require 'sidekiq/web'
require 'sidekiq-scheduler/web'

# Configure Sidekiq Web UI Authentication
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  # Use environment variables mapping to specific credentials
  # fallback to random secure strings if not set to prevent unauthorized access
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_WEB_USER", SecureRandom.hex))) &
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_WEB_PASSWORD", SecureRandom.hex)))
end if Rails.env.production?

Rails.application.routes.draw do
  get 'campaigns/index'
  mount Sidekiq::Web => '/sidekiq'
  get 'line_bot/callback'
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  
  resources :push_subscriptions, only: [:create]

  resources :point_activity_targets do
    collection do
      post :upsert
      get :ensure_current_month_target
    end
  end
  
  resources :campaigns, only: [:index]
  resources :point_activity_gets, except: [:show] do
    collection do
      get :bulk_new
      post :bulk_create
    end
  end
  resources :achievements, only: [:index]
  post '/callback', to: 'line_bot#callback'

  root "dashboards#index"
end
