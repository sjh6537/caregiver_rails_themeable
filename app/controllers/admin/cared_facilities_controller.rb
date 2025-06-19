class Admin::CaredFacilitiesController < ApplicationController
  protect_from_forgery with: :null_session # 關閉 CSRF 驗證
  before_action :authenticate_token!, only: [:new_event]
  include LineHelper
  include ReportHelper

  def authenticate_token!
    token = request.headers['Authorization']&.split(' ')&.last
    unless token && token == APP_CONFIG[:token_secret]
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    true
  end

  def new_event
    device_id = params[:cared_facility_id].to_i
    community_id = params[:community_id].to_i

    begin
      data = JSON.parse(request.body.read)
      data_event_type = data["event_type"]

      # 根據裝置 ID 找出設備
      device = CaredFacility.find_by(id: device_id)

      #
      event_type = CaredFacilityEventType.find_by(name: data_event_type)

      if device.nil?
        render json: { error: "Device not found" }, status: :not_found
        return
      end

      # 找出綁定的使用者
      user = device.cared_user

      if user.nil?
        render json: { error: "Device not bound to any user" }, status: :not_found
        return
      end

      # 儲存event
      event = CaredFacilityEvent.create!(
        cared_facility_event_type_id: event_type.id,
        cared_facility_id: device.id,
        cared_user_info_id: user.id,
        processed: false,
        processed_at: nil,
        processed_note: nil
      )

      send_report_notification(user, event)

      render json: {
        message: "Event received",
        event_id: event.id,
        user_id: user.id
      }, status: :created
    rescue JSON::ParserError => e
      render json: { error: "Invalid JSON: #{e.message}" }, status: :bad_request
    rescue => e
      Rails.logger.error "Create failed: #{e.message}"
      render json: { error: "Internal error" }, status: :internal_server_error
    end
  end

  def send_report_notification(user, event)
    user_text = "緊急通報"
    # 發送給用戶
    message_push(user.account, user_text) if user.profile.present? and user&.line_token.present?

    # 發送給所有照護者
    caregivers = user.caregivers
    return if caregivers.empty?

    caregiver_text = "您的照顧者「#{user.name}」有緊急通報\n\n"
    caregivers.each do |caregiver|
      message_push(caregiver.account, caregiver_text) if caregiver.profile.present? and caregiver&.line_token.present?
    end
  end

end
