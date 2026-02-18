class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :resolve_community_for_theme
  before_action :prepend_theme_view_paths

  helper_method :current_community, :current_theme_key, :current_layout_preset, :admin_subdomain_request?

  def page_not_found
    redirect_to error_not_found_path
    # raise ActionController::RoutingError.new('Not Found')
  end

  def current_community
    @current_community
  end

  def current_theme_key
    return "admin" if admin_subdomain_request?

    current_community&.safe_theme_key.presence || "valex"
  end

  def current_layout_preset
    return "admin" if admin_subdomain_request?

    current_community&.safe_layout_preset.presence || "valex"
  end

  private

  def set_locale
    # 可以將 ["en", "zh-TW"] 設定為 VALID_LANG 放到 config/environment.rb 中
    session[:locale] = params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def resolve_community_for_theme
    set_community_by_token

    @current_community = CommunityResolver.new(
      request: request,
      params: params,
      session: session,
      admin_subdomain_request: admin_subdomain_request?,
      current_user: respond_to?(:current_user) ? current_user : nil,
      current_admin: respond_to?(:current_admin) ? current_admin : nil
    ).resolve

    Current.community = @current_community
  end

  def set_community_by_token
    sn = params[:sn].to_s.strip
    return if sn.blank?

    if session[:sn].present? && session[:sn] != sn && respond_to?(:user_signed_in?) && user_signed_in?
      current_path = request.path
      sign_out(current_user) if respond_to?(:sign_out)
      session[:sn] = sn
      flash[:notice] = I18n.t("Website.Note.Community_Change", sn: sn)
      redirect_to new_user_session_path(sn: sn, return_to: "#{current_path}?sn=#{sn}") and return
    end

    session[:sn] = sn
  end

  def prepend_theme_view_paths
    theme_paths = []

    if current_community&.sn.present?
      theme_paths << Rails.root.join("app/themes/communities", sanitize_theme_segment(current_community.sn), "views")
    end

    theme_paths << Rails.root.join("app/themes", sanitize_theme_segment(current_theme_key), "views")

    fallback_theme = admin_subdomain_request? ? "admin" : "valex"
    if sanitize_theme_segment(current_theme_key) != fallback_theme
      theme_paths << Rails.root.join("app/themes", fallback_theme, "views")
    end

    theme_paths.each do |theme_path|
      prepend_view_path(theme_path.to_s) if Dir.exist?(theme_path)
    end
  end

  def sanitize_theme_segment(value)
    value.to_s.downcase.gsub(/[^a-z0-9_-]/, "")
  end

  def admin_subdomain_request?
    configured_admin_subdomain = APP_CONFIG[:admin_subdomain].to_s.downcase
    return false if configured_admin_subdomain.blank?

    host = request.host.to_s.downcase
    request_subdomain = request.subdomain.to_s.downcase

    request_subdomain == configured_admin_subdomain ||
      host == configured_admin_subdomain ||
      host.start_with?("#{configured_admin_subdomain}.")
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
    if resource.class.name == 'Admin'
      admin_root_path
    elsif resource.class.name == 'User'
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
