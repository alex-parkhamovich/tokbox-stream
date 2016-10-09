Rails.application.routes.draw do
  resources :streams
  devise_for :users

  root 'streams#index'
end
