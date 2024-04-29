Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

    #================= Admin Subdomain =============================
    constraints subdomain: APP_CONFIG[:admin_subdomain] do

      # admin account create by super admin , so don't need registrations....
      devise_for :admin, skip: [:sessions,:registrations,:confirmations,:passwords]
      as :admin do
        get       'login'   , to: 'admin/sessions#new'     , as: :new_admin_session
        post      'login'   , to: 'admin/sessions#create'  , as: :admin_session
        delete    'logout'  , to: 'admin/sessions#destroy' , as: :destroy_admin_session
      end

      namespace :admin, path: '/' do

          root to: 'dashboard#index', as: :root
          resources :admins
      end

    end

    #================= User Subdomain =============================
    #user subdomain chang to customer account , verify in application

    # user account create by cus_admin , so don't need registrations....
    devise_for :user, skip: [:sessions,:registrations,:confirmations]
    as :user do
      get      '/login'       , to: 'user/sessions#new'     , as: :new_user_session
      get      '/linelogin'   , to: 'user/sessions#line'    , as: :line_session
      post     '/login'       , to: 'user/sessions#create'  , as: :user_session
      delete   '/logout'      , to: 'user/sessions#destroy' , as: :destroy_user_session
    end


end
