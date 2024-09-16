get :signup, to: "users#new"
post :signup, to: "users#create"

resources :users, param: :username, only: [:index, :show]