class ApplicationController < ActionController::Base
  before_action :set_locale

  theme :theme_select

  def page_not_found
    redirect_to error_not_found_path
    # raise ActionController::RoutingError.new('Not Found')
  end

  private

  def set_locale
    # 可以將 ["en", "zh-TW"] 設定為 VALID_LANG 放到 config/environment.rb 中
    session[:locale] = params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def theme_select
    if request.subdomain.eql? APP_CONFIG[:admin_subdomain]
      :admin
    else
      :valex
    end
  end

  def authenticate_with_customer_account
    customer = customer_subdomain
    if customer.nil?
      redirect_to error_not_found_path
    elsif request.path.split('/')[1] == APP_CONFIG[:vip_path]
      redirect_to error_not_found_path if current_customer_admin.customer.account != customer.account
    elsif current_user.customer.account != customer.account
      redirect_to error_not_found_path
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :user
      new_user_session_path
    elsif resource_or_scope == :admin
      new_admin_session_path
    else
      super
    end
  end

  def after_sign_in_path_for(resource)
    if resource.instance_of?(::Admin)
      admin_root_path
    elsif resource.instance_of?(::User)
      root_path
    else
      super
    end
  end

  def current_time
    Time.now.localtime.strftime('%Y-%m-%d %R')
  end

  def add_log(action, source, source_id, target, target_id, data = nil)
    description  = log_type_name(source, source_id)
    description += LOG_TYPE_TEXT[source]
    description += " #{LOG_ACTION_TEXT[action]} "
    description += log_type_name(target, target_id)
    description += LOG_TYPE_TEXT[target]
    description += "，#{data}" unless data.nil?
    HistoryLog.create(action: action, source: source, source_id: source_id, target: target, target_id: target_id,
                      data: data, description: description)
  end

  def log_type_name(category, id)
    text = case category
           when LOG_ADMIN
             Admin.find_by_id(id).try(:account)
           when LOG_USER
             User.find_by_id(id).try(:name)
           when LOG_USERCOIN
             User.find_by_id(id).try(:name)
           when LOG_USERCOUPON
             User.find_by_id(id).try(:name)
           when LOG_USERFRIEND
             User.find_by_id(id).try(:name)
           when LOG_SHOP
             Shop.find_by_id(id).try(:name)
           when LOG_SHOPCOUPON
             Coupon.find_by_id(id).try(:name)
           when LOG_REQUEST
             User::Request.find_by_id(id).try(:text)
           when LOG_REQUEST_CATEGORY
             RequestCategory.find_by_id(id).try(:text)
           when LOG_MESSAGE
             ScheduleMessage.find_by_id(id).try(:message_text)
           end
    text = '' if text.nil?
    text
  end
end
