Rails.application.routes.draw do
  
  root 'static_pages#home'   # equivalente a get '/', to: 'static_pages#home', as: 'root'
  
  # get :help, to: 'static_pages#help'
  
  get :about, to: 'static_pages#about'
  
  resource :user, as: :me, path: :me, only: :nil do
    member do
      get '/', action: :profile, as: :profile
      get :credential
      post :credential, to: "users#authenticate"
      get :setting
      patch :setting, to: "users#update"
      delete '/', to: "users#destroy", as: :remove
    end
  end
  resolve('User') { [:user] }
  
  
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  patch "/remember_me", to: "sessions#toggle_status"
  patch "/forget_me", to: "sessions#toggle_status"
  delete "/logout", to: "sessions#destroy"   # usando delete no ocurre el redirect esperado cuando se hace un logout
                                             # y seguidamente se emite otro desde otra ventana del mismo navegador.
                                             # A causa de la peticion delete manejada por turbo_stream,
                                             # Puma me dice: Can't verify CSRF token authenticity.
                                             # Cambie entonces a: get "/logout", to: "sessions#logout"
                                             # Pero esto me cierra la sesion con solo pasar el mouse sobre el enlace logout
                                             # en el menu desplegable del usuario
  
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  resources :users, param: :username, only: [:index, :show]
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
