Rails.application.routes.draw do

  root "schedules#index"
  devise_for :users  # if using Devise

  resources :schedules, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :tasks, only: [:new, :create, :edit, :update, :destroy]
    resources :messages, only: [:create]
  end
end
