Rails.application.routes.draw do
  devise_for :users  # if using Devise

  root "schedules#index"

  resources :schedules, only: [:index, :show, :create, :destroy] do
    resources :tasks, only: [:new, :create, :edit, :update, :destroy]
    resources :messages, only: [:create]
  end
end
