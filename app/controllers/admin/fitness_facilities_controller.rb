class Admin::FitnessFacilitiesController < ApplicationController
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
    device_id = params[:fitness_device_id].to_i
    community_id = params[:community_id].to_i

    begin
      data = JSON.parse(request.body.read)
      report_date = data["report_date"]

      # 根據裝置 ID 找出設備
      device = FitnessDevice.find_by(id: device_id)

      if device.nil?
        render json: { error: "Device not found" }, status: :not_found
        return
      end

      # 找出綁定的使用者
      user = device.user

      if user.nil?
        render json: { error: "Device not bound to any user" }, status: :not_found
        return
      end

      # 建立健身報告
      report = User::FitnessReport.create!(
        user_id: user.id,
        exercise_type: '律動機',
        fitness_device_id: device.id,
        report_date: Date.strptime(report_date, "%Y/%m/%d"),
        start_time: Time.now,
        end_time: Time.now + 10.minutes,
        duration: 600,
        intensity: 3,
        calories_burned: 50.0
      )

      render json: {
        message: "Report created",
        report_id: report.id,
        user_id: user.id
      }, status: :created
    rescue JSON::ParserError => e
      render json: { error: "Invalid JSON: #{e.message}" }, status: :bad_request
    rescue => e
      Rails.logger.error "Create failed: #{e.message}"
      render json: { error: "Internal error" }, status: :internal_server_error
    end
  end

end
