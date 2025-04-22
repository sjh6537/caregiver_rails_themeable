# frozen_string_literal: true

class Web::FitnessReportsController < ApplicationWebController
  include LineHelper

  def new
    @report = current_user.fitness_reports.new
    @title_sub = I18n.t(:NEW, scope: 'Title')
  end

  def create
    @report = current_user.fitness_reports.new(fitness_report_params)
    if @report.save
      redirect_to web_user_fitness_report_path, notice: I18n.t('Notice.Created_Record')
    else
      flash.now[:alert] = t('Notice.Created_Fail', name: t('Table.Fitness_Report'))
      render :new, status: :unprocessable_entity
    end
  end

  def fitness_report_params
    # 定義允許傳遞的參數，確保安全性
    params.require(:user_fitness_report).permit(
      :exercise_type,
      :fitness_device_id,
      :start_time,
      :end_time,
      :duration,
      :calories_burned,
      :intensity
      # 加入其他您需要的欄位
    )
  end
end
