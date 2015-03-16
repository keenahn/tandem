Rails.application.routes.draw do
  resources :pairs

  get 'main/index'

  resources :groups do
    resources :pairs
    resources :members do
      post "/bulk_import" => "members#bulk_import", on: :collection
    end
  end

  resources :members

  devise_for :users, controllers: {registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords"}, skip: [:sessions, :registrations]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#index'

  #->Prelang (user_login:devise/stylized_paths)
  devise_scope :user do
    get    "login"   => "users/sessions#new",         as: :login
    post   "login"   => "users/sessions#create"
    delete "logout"  => "users/sessions#destroy",     as: :logout

    get    "signup"  => "users/registrations#new",    as: :signup
    post   "signup"  => "users/registrations#create"
    put    "signup"  => "users/registrations#update"
    get    "account" => "users/registrations#edit",   as: :edit_user
  end

end
