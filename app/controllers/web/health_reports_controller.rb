class Web::HealthReportsController < ApplicationWebController
  include LineHelper

  def new
    @health_report = current_user.health_reports.new
    @title_sub = I18n.t(:NEW, scope: 'Title')
  end

  def create
    params = health_report_params.merge(measure_time: Time.current)
    @health_report = current_user.health_reports.new(params)

    if @health_report.save
      # 發送 Line 通知給用戶
      send_report_notification(@health_report)
      redirect_to web_user_health_report_path, notice: I18n.t('Notice.Created_Record')
    else
      @title_sub = I18n.t(:NEW, scope: 'Title')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def health_report_params
    if params[:user_health_report].present?
      params.require(:user_health_report).permit(
        :bmi, :weight, :temperature, :blood_pressure1, :blood_pressure2,
        :heart_rate, :blood_sugar, :blood_oxygen, :hemoglobin,
        :hematocrit, :uric_acid, :ketones, :total_cholesterol
      )
    else
      {}
    end
  end

  def send_report_notification(report)
    text = "你有一份新的健康報告：\n\n"
    text += "#{I18n.t('Table.BMI')}: #{report.bmi}\n" if report.bmi.present?
    text += "#{I18n.t('Table.Weight')}: #{report.weight}\n" if report.weight.present?
    text += "#{I18n.t('Table.Temperature')}: #{report.temperature}\n" if report.temperature.present?
    text += "#{I18n.t('Table.Blood_Pressure1')}: #{report.blood_pressure1}\n" if report.blood_pressure1.present?
    text += "#{I18n.t('Table.Blood_Pressure2')}: #{report.blood_pressure2}\n" if report.blood_pressure2.present?
    text += "#{I18n.t('Table.Heart_Rate')}: #{report.heart_rate}\n" if report.heart_rate.present?
    text += "#{I18n.t('Table.Blood_Sugar')}: #{report.blood_sugar}\n" if report.blood_sugar.present?
    text += "#{I18n.t('Table.Blood_Oxygen')}: #{report.blood_oxygen}\n" if report.blood_oxygen.present?

    # 發送給用戶
    message_push(current_user.account, text)

    # 發送給照護者
    caregiver = current_user.caregivers.first
    return unless caregiver.present?

    caregiver_text = "你的照護對象「#{current_user.name}」有一份新的健康報告：\n\n" + text
    message_push(caregiver.account, caregiver_text)
  end
end
