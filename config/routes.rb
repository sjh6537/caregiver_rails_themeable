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
          resources :users
          get       'users/:id/push'    , to: 'users#push'     , as: :push_admin_user
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

    get      ''                       , to: 'web/dashboard#index'                , as: :root
    get      '/error'                 , to: 'web/notice#error'                   , as: :error_notice

    get      '/user'                  , to: 'web/user#show'                      , as: :web_user_show
    get      '/user/edit'             , to: 'web/user#edit'                      , as: :web_user_edit
    patch    '/user'                  , to: 'web/user#update'                    , as: :web_user_update

    get      '/requests'                  , to: 'web/requests#index'             , as: :web_requests
    get      '/requests/new/:category'    , to: 'web/requests#new'               , as: :web_request_new
    post     '/requests'                  , to: 'web/requests#create'            , as: :web_request
    get      '/requests/friends'          , to: 'web/requests#friends'           , as: :web_request_friends
    get      '/requests/:id'              , to: 'web/requests#show'              , as: :web_request_show
    delete   '/requests/:id'              , to: 'web/requests#delete'            , as: :web_request_delete

    post     '/line_notify'         , to: 'linemsg#notify'                  , as: :line_notify
    post     '/line_push'           , to: 'linemsg#push'                    , as: :line_push
    post     '/line_push_all'       , to: 'linemsg#broadcast'               , as: :line_broadcast

end
