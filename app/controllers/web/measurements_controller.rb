class Web::MeasurementsController < ApplicationWebController
  include LineHelper
  include ReportHelper

  def new
    @user = current_user
    @health_report = current_user.health_reports.new
  end

  def create
    params = measurement_params.merge(measure_time: Time.current)
    params = apply_body_composition(params)
    # 確保 model 的欄位資訊為最新（當在執行中套用 migration 時會需要）
    User::HealthReport.reset_column_information
    @health_report = current_user.health_reports.new(params)

    if @health_report.save
      # send_report_notification(@health_report)
      redirect_to web_user_measurements_path, flash: { my_notice: I18n.t('Notice.Created_Record') }
    else
      @user = current_user
      render :new, status: :unprocessable_entity
    end
  end

  private

  def measurement_params
    if params[:user_health_report].present?
      params.require(:user_health_report).permit(
        :bmi, :height, :weight, :body_fat, :bmr, :temperature, :blood_pressure1,
        :blood_pressure2, :heart_rate, :blood_sugar, :blood_oxygen
      )
    else
      {}
    end
  end

  def apply_body_composition(params)
    return params if params[:height].blank? || params[:weight].blank?
    return params if params[:bmi].present?

    height_m = params[:height].to_f / 100.0
    return params if height_m <= 0

    params.merge(bmi: (params[:weight].to_f / (height_m * height_m)).round(1))
  end

  def send_report_notification(report)
    text = format_health_report(report)
    message_push(current_user.account, text)

    caregivers = current_user.caregivers
    return if caregivers.empty?

    caregivers.each do |caregiver|
      caregiver_text = "您的照顧者「#{current_user.name}」有新的健康報告：\n\n" + text
      message_push(caregiver.account, caregiver_text) if caregiver.line_token.present?
    end
  end
end
