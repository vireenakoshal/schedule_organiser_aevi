Rails.application.routes.draw do
  devise_for :users, sign_out_via: :get
  root "schedules#index"

  resources :schedules, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :tasks, only: [:create, :destroy, :edit, :update] do
      collection do
        post :create_with_ai
      end
      member do
        patch :toggle_complete
      end
    end
    resources :messages, only: [:create]
    resources :suggestions, only: [:new, :create]
  end
end
