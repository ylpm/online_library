Rails.application.routes.draw do
  
  root 'static_pages#home'   # equivalente a get '/', to: 'static_pages#home', as: 'root'
  
  get :help, to: 'static_pages#help'
  
  get :about, to: 'static_pages#about' 
  
  get "/login", to: "sessions#new"
  
  post "/login", to: "sessions#create"
  
  delete "/logout", to: "sessions#destroy"
  
  resources :users, only: [:create, :destroy]
  
  get :signup, to: "users#new"
  
  get "/:username", to: "users#profile", as: :user_profile
  
  get "/:username/settings", to: "users#settings", as: :user_settings
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
