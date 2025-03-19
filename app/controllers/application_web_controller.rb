class ApplicationWebController < ApplicationController
  before_action :set_user_based_on_environment

  private

  def set_user_based_on_environment
    if Rails.env.production?
      authenticate_user! # 在 production 環境下驗證用戶
    else
      set_current_user # 在 development 環境下設置預設用戶
    end
  end

  def set_current_user
    authenticate_user!
    # @current_user = User.find(1) # 設置預設用戶
  end

  def set_community_by_token
    sn = params[:sn]
    if sn.present?
      session[:sn] = sn
      Rails.logger.info "設置社區 sn: #{sn}"
    else
      Rails.logger.info "沒有提供社區 sn"
    end
  end

  def current_community
    puts 'current_community_sn ' + session[:sn].to_s

    # 查找實際的 Community 對象而不是使用 session 中的值
    sn = session[:sn]
    @current_community ||= Community.find_by(sn: sn)

    if @current_community.nil?
      redirect_to error_notice_path, notice: 'community not found'
      return nil
    end
    puts 'current_community: ' + @current_community.sn.to_s
    @current_community
  end
end
