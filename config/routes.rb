Rails.application.routes.draw do
  root "point_activities#index"
  devise_for :users
end
