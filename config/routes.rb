Rails.application.routes.draw do
  root to: 'pages#index'
  resources :crimes, only: [:near_crimes]
end