module ApplicationHelper
  def get_postal_selection(city_code)
    html_text = ''
    POSTAL_CODE.map do |p|
      if p[:city] == city_code
        tmp_text = "<option value=#{p[:code]} descrition=\"#{p[:name]}\">#{p[:name]}</option>"
        html_text += tmp_text
      end
    end
    html_text.html_safe
  end

  def get_city(code)
    city = CITY_CODE.select { |c| c[:code] == code }.first
    return city[:city] unless city.nil?

    nil
  end

  def get_postal_city(postal_code)
    postal = POSTAL_CODE.select { |c| c[:code] == postal_code }.first
    return postal[:city] unless postal.nil?

    nil
  end

  def get_postal(code)
    postal = POSTAL_CODE.select { |c| c[:code] == code }.first
    return postal[:name] unless postal.nil?

    nil
  end

  def create_current_list
  end

  def append_user(account, id_card)
  end

  def request_category_all
    RequestCategory.where(is_show: true)
  end

  def request_category_text(id)
    if RequestCategory.find_by_id(id).nil?
      '其他'
    else
      RequestCategory.find_by_id(id).text
    end
  end

  def set_community_by_token
    sn = params[:sn]
    if sn.present?
      # 檢查是否需要重新登入（社區切換）
      if session[:sn].present? && session[:sn] != sn && user_signed_in?
        Rails.logger.info "社區變更，從 #{session[:sn]} 切換到 #{sn}，需要重新登入"

        # 保存當前請求信息，但保留 sn 參數
        current_path = request.path

        # 登出當前用戶
        Rails.logger.warn '登出使用者'
        sign_out(current_user)

        # 將新社區的 sn 存入 session
        session[:sn] = sn

        # 設置提示信息
        flash[:notice] = I18n.t('Website.Note.Community_Change', sn: sn)
        Rails.logger.info "社區變更，從 #{session[:sn]} 切換到 #{sn}，需要重新登入"

        # 重定向到登入頁面，帶上社區參數和返回 URL
        redirect_to new_user_session_path(sn: sn, return_to: "#{current_path}?sn=#{sn}") and return
      end

      session[:sn] = sn
      # 確保session確實被設置
      Rails.logger.info "設置社區 sn: #{sn}, 設置後session[:sn]值: #{session[:sn]}"
    elsif session[:sn].present?
      Rails.logger.info "使用 session 中的 sn: #{session[:sn]}"
    else
      Rails.logger.warn 'params[:sn] 和 session[:sn] 都為空'
    end
  end

  def current_community
    set_community_by_token
    Rails.logger.info "讀取session中的sn: #{session[:sn].inspect}"

    # 查找實際的 Community 對象而不是使用 session 中的值
    sn = session[:sn]

    if sn.blank?
      Rails.logger.warn 'session[:sn]為空，無法找到社區'
      return nil
    end

    @current_community ||= Community.find_by(sn: sn)

    if @current_community.nil?
      Rails.logger.warn "找不到社區，sn: #{sn}"
      return nil
    end

    Rails.logger.info "找到社區: #{@current_community.sn}"
    @current_community
  end
end
