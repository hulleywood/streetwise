Rails.application.routes.draw do
  root to: 'pages#index'
  resources :directions, only: [:show]
end