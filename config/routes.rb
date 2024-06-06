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
        get       'logout'  , to: 'admin/sessions#destroy' , as: :destroy_admin_session
      end

      namespace :admin, path: '/' do
          root to: 'dashboard#index', as: :root
          resources :admins

          resources :users, except: [:destroy]
          delete    'users/:id'             , to: 'users#block'           , as: :user_block
          post      'users/send_message'    , to: 'users#send_message'    , as: :line_msg_admin_user
          get       'users/:id/push'        , to: 'users#push'            , as: :push_page_admin_user

          resources :shops

          namespace :shop, path: '/' do
            get      'shop/:shop_id/coupons/new'      , to: 'coupons#new'               , as: :new_coupon
            post     'shop/:shop_id/coupons/'         , to: 'coupons#create'            , as: :coupons
            get      'shop/:shop_id/coupon/:id/edit'  , to: 'coupons#edit'              , as: :edit_coupons
            patch    'shop/:shop_id/coupon/:id'       , to: 'coupons#update'            , as: :update_coupons
            delete   'shop/:shop_id/coupon/:id'       , to: 'coupons#destroy'           , as: :destroy_coupons
          end
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
      get      '/logout'           , to: 'user/sessions#destroy'            , as: :destroy_user_session
    end

    get      ''                             , to: 'web/dashboard#index'            , as: :root
    get      '/error'                       , to: 'web/notice#error'               , as: :error_notice

    get      '/user'                        , to: 'web/user#show'                  , as: :web_user_show
    get      '/user/friends'                , to: 'web/user#friends'               , as: :web_user_friends
    get      '/user/requests'               , to: 'web/user#requests'              , as: :web_user_requests
    get      '/user/coupons'                , to: 'web/user#coupons'               , as: :web_user_coupons
    post     '/user/coupons/redeem/:id'     , to: 'web/user#coupons_redeem'        , as: :web_user_coupons_redeem
    get      '/user/edit'                   , to: 'web/user#edit'                  , as: :web_user_edit
    patch    '/user'                        , to: 'web/user#update'                , as: :web_user_update

    #get      '/requests'                    , to: 'web/requests#index'             , as: :web_requests
    get      '/requests/new/:category'      , to: 'web/requests#new'               , as: :web_request_new
    post     '/requests'                    , to: 'web/requests#create'            , as: :web_request
    get      '/requests/:id/friends'        , to: 'web/requests#friends'           , as: :web_request_friends
    get      '/requests/:id'                , to: 'web/requests#show'              , as: :web_request_show
    post     '/requests/:id/pushed'         , to: 'web/requests#pushed'            , as: :web_request_pushed
    get      '/requests/:id/shared'         , to: 'web/requests#shared'            , as: :web_request_shared
    delete   '/requests/:id'                , to: 'web/requests#delete'            , as: :web_request_delete
    get      '/requests/:id/agree'          , to: 'web/requests#agree'             , as: :web_request_agree
    delete   '/requests/:id/agree'          , to: 'web/requests#agree_delete'      , as: :web_request_agree_delete

    get      '/accept/:id/show'             , to: 'web/accept#show'                , as: :web_accept_show
    get      '/accept/:id/agree'            , to: 'web/accept#agree'               , as: :web_accept_agree
    get      '/accept/edit'                 , to: 'web/accept#edit'                , as: :web_accept_edit
    patch    '/accept/update'               , to: 'web/accept#update'              , as: :web_accept_update
    get      '/accept/join'                 , to: 'web/accept#join'                , as: :web_accept_join

    get      '/invite/:friend_id'           , to: 'web/invite#edit'                , as: :web_invite_edit

    get      '/liff/url_to'                 , to: 'liff#url_to'                    , as: :liff_url_to
    post     '/line_notify'                 , to: 'linemsg#notify'                 , as: :line_notify


    #================= asset =============================
    get       '/coupons/:id/image/:filename'              , to:   'asset#coupons'          , as: :coupon_image
    get       '/coupons/:id/full_image/:filename'         , to:   'asset#coupons_full'     , as: :coupon_image_full

end
