Rails.application.routes.draw do
  root "point_activity_targets#index"
  devise_for :users
  
  resources :point_activity_targets
  resources :point_activity_gets
  
end
