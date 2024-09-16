# Define routes based on the current user, aliased as "me"

resource :user, as: :me, path: :me, only: :nil do
  member do
    get '/', action: :profile, as: :profile
    get :credential
    post :credential, to: "users#authenticate"
    get :setting
    patch :setting, to: "users#update"
    patch :remember, to: "sessions#toggle_status"
    patch :forget, to: "sessions#toggle_status"
    delete :logout, to: "sessions#destroy"
    delete '/', to: "users#destroy", as: :remove
  end
end
resolve('User') { [:user] }