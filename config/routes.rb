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
          get     'users'    , to: 'user#index'             , as: :users
      end

    end

    #================= User Subdomain =============================
    #user subdomain chang to customer account , verify in application

    # user account create by line , so don't need registrations....
    devise_for :user, skip: [:sessions,:registrations,:confirmations]
    as :user do
      get      '/login'            , to: 'user/sessions#new'                , as: :new_user_session
      get      '/authorize'        , to: 'user/sessions#line_authorize'     , as: :line_authorize
      get      '/callback'         , to: 'user/sessions#line_callback'      , as: :line_callback
      delete   '/logout'           , to: 'user/sessions#destroy'            , as: :destroy_user_session
    end

    get      ''                  , to: 'web/dashboard#index'                , as: :root
    get      '/error'            , to: 'web/notice#error'                   , as: :error_notice
    get      '/user'             , to: 'web/user#edit'                      , as: :edit_user

end
