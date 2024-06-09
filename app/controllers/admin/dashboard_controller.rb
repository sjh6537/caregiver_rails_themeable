# -*- encoding : utf-8 -*-
class Admin::DashboardController < ApplicationAdminController

    # GET
    def index
        flash[:notice] = nil
        @history_logs = HistoryLog.all.order(created_at: :desc).limit(10)
    end

end
