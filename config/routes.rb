Rails.application.routes.draw do
  # we have a pages controller
  root to: 'pages#home'
  # createa a movies controller
  resources :movies, only: :index
end
