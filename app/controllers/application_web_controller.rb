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
    # 如果 session[:community] 已存在則直接返回
    return if session[:community].present?

    token = params[:token]
    if token.nil?
      redirect_to error_notice_path, notice: 'invalid token'
      return
    end
    community = Community.find_by(token: token)
    if community.nil?
      redirect_to error_notice_path, notice: 'invalid community'
      return
    end
    session[:community] = community.id
  end

  def current_community
    if session[:community].nil?
      redirect_to error_notice_path, notice: 'invalid community'
      return nil
    end

    # 查找實際的 Community 對象而不是使用 session 中的值
    community_id = session[:community]
    @current_community ||= Community.find_by(id: community_id)

    if @current_community.nil?
      redirect_to error_notice_path, notice: 'community not found'
      return nil
    end

    @current_community
  end
end
