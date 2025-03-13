module Admin
  class DashboardController < ApplicationAdminController
    # GET
    def index
      flash[:notice] = nil
      @history_logs = HistoryLog.all.order(created_at: :desc).limit(10)
      @schedules = ScheduleMessage.order(scheduled_time: :desc)
    end
  end
end
