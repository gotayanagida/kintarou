Rails.application.routes.draw do
  root to: "dashboard#index"
  resources :users
  resources :attendances
  resources :goals
  resources :reports
  resources :schedules
  resources :tasks
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
