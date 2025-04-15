class Admin::CaredFacilitiesController < ApplicationController
  protect_from_forgery with: :null_session # 關閉 CSRF 驗證
  before_action :authenticate_token!, only: [:new_event]

  def authenticate_token!
    token = request.headers['Authorization']&.split(' ')&.last
    unless token && token == APP_CONFIG[:token_secret]
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    true
  end

  def new_event
    data = JSON.parse(request.body.read)
    Rails.logger.info "New event"
  end

end
