# -*- encoding : utf-8 -*-
class Admin::ScheduleMessagesController < ApplicationAdminController
    include LineHelper
    include ApplicationHelper
    before_action :set_admin

    def index
        @title_sub = I18n.t("Title.Table")
        @users = User.all
        @schedules = ScheduleMessage.all
    end

    def new
        @schedule =  ScheduleMessage.new
        @users = User.all
    end

    def create
        @title_sub = I18n.t("Title.New")
        user_ids = params[:schedule_message][:user_ids]
        title    = params[:schedule_message][:schedule_name]
        text     = params[:schedule_message][:message_text]
        time     = params[:schedule_message][:scheduled_time]
        result = create_job(user_ids, title, text, time)

        respond_to do |format|
            if result = true
                add_log(ACTION_NEW,LOG_ADMIN,@admin.id,LOG_MESSAGE,@schedule.id)
                format.html { redirect_to admin_schedule_messages_path, notice: I18n.t("Notify.Note.Schedule_Message_Created", name: "#{@admin.name}", title: "#{title}") }
            else
                format.html { redirect_to admin_schedule_messages_path, notice: I18n.t("Notify.Note.Schedule_Message_Created_Fail", name: "#{@admin.name}") }
            end
        end
    end

    def create_job(user_ids, title, text, time)

        @schedule = ScheduleMessage.new(schedule_name: title, user_ids: user_ids, scheduled_time: time, message_text: text)
        if @schedule.save
            job_id = message_schedule(@schedule.id)
            if job_id == nil
                @schedule.destroy
                return false
            else
                @schedule.update(job_id: job_id)
            end
            return true
        else
            return false
        end
    end

    def destroy
        @schedule = ScheduleMessage.find(params[:id])
        Sidekiq::ScheduledSet.new.find { |job| job.jid == @schedule.job_id } &.delete
        @schedule.destroy
        render json: { redirect_url: admin_schedule_messages_path}, status: :ok
    end

    private

    def set_admin
        @admin = current_admin
    end

    def set_breadcrumb
        @title = I18n.t("Title.LINE_MESSAGE")
        @title_sub = nil
    end
end
