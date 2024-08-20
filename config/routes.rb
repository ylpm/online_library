Rails.application.routes.draw do
  
  root 'static_pages#home'   # equivalente a get '/', to: 'static_pages#home', as: 'root'
  
  get :help, to: 'static_pages#help'
  
  get :about, to: 'static_pages#about'  
  
  resources :users, except: :new
  
  get :signup, to: "users#new"
  
  get :login, to: "sessions#new"
  
  post :login, to: "sessions#create"
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
