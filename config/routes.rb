Rails.application.routes.draw do
  resources :rooms, only: [:create, :update, :index]
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:sessions, :password, :registration]
  devise_scope :user do
    resource :session, only: [], path: 'auth', controller: 'sessions', as: :user_session do
      post "sign_in" => :create
    end
    resource :registration, only: [:create], path: '/auth', controller: 'registrations'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

end
