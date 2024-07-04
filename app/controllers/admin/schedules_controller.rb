class Admin::SchedulesController < ApplicationController
    include LineHelper
    before_action :set_user
    # before_action :clean_up_schedules
    before_action :set_schedule, only: [:show, :edit, :update, :destroy, :clear_event]
    before_action :set_gon_variables

    def index
        @user = User.find(params[:user_id])
        @schedules = @user.schedules.order(scheduled_time: :desc) if @user.present? && @user.schedules.any?
        render 'admin/users/schedules/index'
    end

    def show
        @title_sub = I18n.t("Title.Information")
        respond_to do |format|
            format.html
        end
        render 'admin/users/schedules/show'
    end

    def new
        @user = User.find(params[:user_id])
        @schedule = @user.schedules.new
        @users = User.all
        render 'admin/users/schedules/new'
    end

    def create
        @schedule = @user.schedules.new(schedule_params)
        if @schedule.save
            # schedule_job(@schedule)
            redirect_to admin_user_schedules_path(@user.id)
        else
            render :new
        end
    end

    def edit
        @user = User.find(params[:user_id])
        @schedule = @user.schedules.find(params[:id])
        @users = User.all
        render 'admin/users/schedules/edit'
    end

    def update
        if @schedule.update(schedule_params)
            Sidekiq::ScheduledSet.new.find { |job| job.jid == @schedule.job_id }&.delete
            schedule_job(@schedule)
            redirect_to admin_user_schedules_path(@user.id)
        else
            render :edit
        end
    end

    def destroy
        @schedule = User::Schedule.find(params[:id])
        @schedule.destroy
        Sidekiq::ScheduledSet.new.find { |job| job.jid == @schedule.job_id }&.delete
        render json: { redirect_url: admin_user_schedules_path(@user.id) }, status: :ok
    end

    def setup_schedule
        if params[:text].present? && params[:msgtype].present? && params[:datetime].present? && params[:recipient].present? && params[:id].present?
            text = params[:text]
            type = params[:msgtype].to_i
            user_id = params[:user_id]
            schedule_id = params[:schedule_id]
            input_time = params[:datetime]
            send_time = Time.parse("#{input_time} +0800").getutc
            current_time = DateTime.now.utc

            input_ids = params[:recipient]
            recipients = []
            input_ids.each do |input_id|
                userdb = User.find_by_id(input_id)
                if userdb
                    recipients << userdb.account
                end
            end

            if schedule_id.present?
                @schedule = @user.schedules.find(schedule_id)
                @schedule.update(recipient: recipients, scheduled_time: send_time, message_text: text)
                Sidekiq::ScheduledSet.new.find { |job| job.jid == @schedule.job_id }&.delete
                if @schedule.blank?
                    render json: { status: 'error', message: @schedule.errors.full_messages.join(", ") }, status: :unprocessable_entity
                end
            else
                @schedule = @user.schedules.new(recipient: recipients, scheduled_time: send_time, message_text: text)
            end

            if @schedule.save
                schedule_name = params[:schedule_name].present? ? params[:schedule_name] : "Schedule"
                job_id = message_schedule(send_time, recipients, text)
                if send_time > current_time
                    @schedule.update(job_id: job_id, schedule_name: schedule_name)
                else
                    @schedule.destroy
                end
                render json: { redirect_url: admin_user_schedules_path(user_id) }, status: :ok
            else
                render json: { status: 'error', message: @schedule.errors.full_messages.join(", ") }, status: :unprocessable_entity
            end
        else
            render json: { status: 'error', message: 'Parameter unknown' }, status: :ok
        end
    end

    def clear_event
        jid = params[:jid]
        result = {result: false, content: I18n.t(:Delete_Message_Fail, scope: "Notify.Note")}
        Sidekiq::ScheduledSet.new.each do | job |
            if job.klass == "NotifySender" && job.jid == jid
                job.delete
                result = {result: true, content: I18n.t(:Delete_Message_Success, scope: "Notify.Note")}
                break
            end
        end
        respond_to do |format|
            format.html { render :message }
            format.json { render json: result }
        end
    end

    private

    def set_user
        @user = User.find(params[:user_id])
    end

    def clean_up_schedules
        current_time = DateTime.current
        @user.schedules.where("scheduled_time < ?", current_time).find_each do |schedule|
            delete_sidekiq_job(schedule.job_id)
            schedule.destroy
        end
    end

    def set_schedule
        @schedule = @user.schedules.find(params[:id])
    end

    def schedule_params
        params.require(:schedule).permit(:message_text, :message_image, :schedule_type, :recipient, :scheduled_time)
    end

    def schedule_job(schedule)
        job_id = ScheduleWorker.perform_at(schedule.scheduled_time, schedule.id)
        schedule.update(job_id: job_id)
    end

    def delete_sidekiq_job(job_id)
        job = Sidekiq::ScheduledSet.new.find { |j| j.jid == job_id }
        job.delete if job
    end

    def set_gon_variables
        gon.button_next = I18n.t("Button.NEXT")
        gon.button_previous = I18n.t("Button.PREVIOUS")
        gon.button_finish = I18n.t("Button.FINISH")
        gon.button_cancel = I18n.t("Button.CANCEL")
        gon.tip_error_default_Message = I18n.t("Tip.Error.Default_Message")
        gon.tip_error_type_Email = I18n.t("Tip.Error.Type_Email")
        gon.tip_error_type_Url = I18n.t("Tip.Error.Type_Url")
        gon.tip_error_type_Number = I18n.t("Tip.Error.Type_Number")
        gon.tip_error_type_Integer = I18n.t("Tip.Error.Type_Integer")
        gon.tip_error_type_Digits = I18n.t("Tip.Error.Type_Digits")
        gon.tip_error_type_Alphanum = I18n.t("Tip.Error.Type_Alphanum")
        gon.tip_error_notblank = I18n.t("Tip.Error.Notblank")
        gon.tip_error_required = I18n.t("Tip.Error.Required")
        gon.tip_error_pattern = I18n.t("Tip.Error.Pattern")
        gon.tip_error_min = I18n.t("Tip.Error.Min")
        gon.tip_error_max = I18n.t("Tip.Error.Max")
        gon.tip_error_range = I18n.t("Tip.Error.Range")
        gon.tip_error_minlength = I18n.t("Tip.Error.Minlength")
        gon.tip_error_maxlength = I18n.t("Tip.Error.Maxlength")
        gon.tip_error_length = I18n.t("Tip.Error.Length")
        gon.tip_error_mincheck = I18n.t("Tip.Error.Mincheck")
        gon.tip_error_maxcheck = I18n.t("Tip.Error.Maxcheck")
        gon.tip_error_check = I18n.t("Tip.Error.Check")
        gon.tip_error_equalto = I18n.t("Tip.Error.Equalto")

    end
end
