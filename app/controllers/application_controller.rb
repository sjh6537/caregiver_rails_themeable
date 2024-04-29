class ApplicationController < ActionController::Base
    before_action :set_locale
  
    theme :theme_select
  
    def page_not_found
      redirect_to error_not_found_path
      #raise ActionController::RoutingError.new('Not Found')
    end
  
    private
  
    def set_locale
      # 可以將 ["en", "zh-TW"] 設定為 VALID_LANG 放到 config/environment.rb 中
      if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
        session[:locale] = params[:locale]
      end
  
      I18n.locale = session[:locale] || I18n.default_locale
    end
  
    def theme_select
      if request.subdomains.first.eql? APP_CONFIG[:admin_subdomain]
        :admin
      # elsif request.path.split('/')[1] == APP_CONFIG[:vip_path]
      #  :admin
      else
        :valex
      end
    end
   
    def authenticate_with_customer_account
      customer = customer_subdomain
      if customer == nil
        redirect_to error_not_found_path
      elsif request.path.split('/')[1] == APP_CONFIG[:vip_path]
        if current_customer_admin.customer.account != customer.account
          redirect_to error_not_found_path
        end
      elsif current_user.customer.account != customer.account
        redirect_to error_not_found_path
      end
    end
  
    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      if resource_or_scope == :customer_admin
        new_customer_admin_session_path
      elsif resource_or_scope == :user
        user_school_root_path
      elsif resource_or_scope == :admin
        new_admin_session_path
      else
        super
      end
    end
  
    def after_sign_in_path_for(resource)
      if resource.class.name == "CustomerAdmin"
  
        customer_school_root_path
  
      elsif resource.class.name == "User"
        user_school_root_path
      else
        super
      end
    end
  
    def current_time
      Time.now.localtime.strftime('%Y-%m-%d %R')
    end
  end
  