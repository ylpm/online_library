Rails.application.routes.draw do
  
  root 'static_pages#home'   # equivalente a get '/', to: 'static_pages#home', as: 'root'
  
  # draw :static_pages
  #
  # draw :users
  #
  # draw :sessions
  #
  # draw :current_user
  
  APP_ROUTES = Dir[Rails.root.join('config/routes/*.rb')].map { |file| File.basename(file, '.rb').to_sym }  
  APP_ROUTES.each {|routes| draw routes}
    
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
