require 'public_api_constraints'
Rails.application.routes.draw do
  namespace :api do
    resources :vehicles, only: [:index] do
      member do
        get :emission_tests
        get :daily_reports
      end
    end
    resources :companies, only: [:index, :create, :update, :destroy]
    resources :locations, only: [:index, :create, :update]
    resources :users, only: [:index, :create, :update]
    resources :engine_configs, only: [:update]
    get 'inputs/:id/diagnostic', to: 'diagnostic#show'
    get 'debug/engine_configs', to: 'debug#engine_configs'
    get 'debug/parameters', to: 'debug#parameters'
  end
  devise_for :users,
    skip: [:registrations],
    path_names: { sign_in: 'login', sign_out: 'logout' },
    path_prefix: 'secure'
  devise_scope :user do
    get '/secure/api/current_user' => 'users/sessions#show_current_user'
    post 'secure/api/check/is_user' => 'users/users#is_user', as: 'is_user'
    put '/secure/api/current_user/change_password' => 'users/users#change_password'
  end
  namespace :secure do
    root to: "home#index"
    namespace :api do
      resources :users do
        collection { put 'current_change_password' }
      end
      resources :inputs do
        collection { get 'export' }
      end
      resources :valid_emission_tests
      resources :outputs
      resources :engines
      resources :vehicles
      resources :companies
      resources :locations
      resources :parameters
      resources :drive_types
      resources :manufacturers
      resources :engine_configs
      resources :vehicle_stats do
        collection do
          post 'import_stat_file'
          post 'import_stat_all_files'
          get 'export'
        end
      end
    end
  end
  root to: "home#index"
end
