class Admin::UsersController < ApplicationAdminController
  include LineHelper
  include ApplicationHelper
  before_action :set_user, except: %i[all_schedules delete_schedules]

  def index
    @title_sub = I18n.t('Title.Table')
    # 超級管理者可查看所有使用者，一般管理者只能查看同社區使用者
    @users = if current_admin.super_admin?
               User.all
             else
               Rails.logger.info "Found current_admin.community_id : #{current_admin.community_id}"
               User.where(community_id: current_admin.community_id)
             end
  end

  def new
    @title_sub = I18n.t('Title.New')
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @title_sub = I18n.t('Title.New')
    @user = User.new(admin_params)
    respond_to do |format|
      if @user.save
        format.html do
          redirect_to admin_users_path, notice: I18n.t('Notify.Note.Account_Created', name: "#{@user.line_name}")
        end
      else
        format.html do
          render action: 'new', alert: I18n.t('Notify.Note.Account_Created_Fail', name: "#{@user.line_name}")
        end
      end
    end
  end

  def show
    @title_sub = I18n.t('Title.Information')
    @history_coins = @user.history_coins
    respond_to do |format|
      format.html
    end
  end

  def health_report
    @title_sub = I18n.t('Title.HEALTH_REPORT')
    @user = User.find_by_id(params[:id])
    @reports = @user.health_reports.order(id: :desc)
  end

  def fitness_report
    @title_sub = I18n.t('Title.FITNESS_REPORT')
    @user = User.find_by_id(params[:id])
    @reports = @user.fitness_reports.order(id: :desc)
  end

  def edit
    @title_sub = I18n.t('Title.Edit')
  end

  def update
    @title_sub = I18n.t('Title.Edit')
    # if current_admin.super_user == false
    #   result = @user.update_without_password(admin_params)
    # else
    result = if params[:user][:account].present?
               @user.update(admin_params)
             else
               @user.update_without_password(admin_params)
             end
    # end

    respond_to do |format|
      if result
        add_log(ACTION_EDIT, LOG_ADMIN, current_admin.id, LOG_USER, @user.id)
        append_user('%010d' % @user.id , @user.id_card)
        format.html do
          redirect_to admin_users_path, notice: I18n.t('Notify.Note.Account_Updated', name: "#{@user.line_name}")
        end
      else
        format.html do
          render action: 'edit', alert: I18n.t('Notify.Note.Account_Updated_Fail', name: "#{@user.line_name}")
        end
      end
    end
  end

  def block
    respond_to do |format|
      if @user.update(enable: false)
        add_log(ACTION_BLOCK, LOG_ADMIN, current_admin.id, LOG_USER, @user.id)
        format.html do
          redirect_to admin_users_path, notice: I18n.t('Notify.Note.Account_Blocked', name: "#{@user.line_name}")
        end
      else
        format.html do
          redirect_back fallback_location: '/',
                        alert: I18n.t('Notify.Note.Account_Blocked_Fail',
                                      name: "#{@user.line_name}")
        end
      end
    end
  end

  def push
  end

  def send_message
    if params[:text].present? && params[:msgtype].present?
      text = params[:text]
      type = params[:msgtype].to_i

      case type
      when LINE_MSG_TYPE_TEXT
        message = message_package_text(text)
      end

      lineuser = User.find_by_id(params[:id])
      username = lineuser.line_name
      if !params[:id].present? || (params[:id] == 'null')
        message_push(nil, text)
        render json: { status: 'success', message: I18n.t('Website.Note.Line_send_group_success') }, status: :ok
        return
      else
        message_push(lineuser.account, text)
        render json: { status: 'success', message: I18n.t('Notify.Note.Line_send_person_success', name: "#{username}") },
               status: :ok
        return
      end
    end

    render json: { status: 'error', message: 'Parameter unknown' }, status: :ok
    nil
  end

  def coins_deliver
    coins = params[:number].to_i
    @user.coins_get(coins , COINS_GET_SYSTEM , current_admin.id , I18n.t('Notify.Note.Deliver_Coins_Success'))
    add_log(ACTION_ADD, LOG_ADMIN, current_admin.id, LOG_USERCOIN, @user.id, "#{coins}枚")
    redirect_to admin_user_path(@user.id)
  end

  def all_schedules
    @schedules = User::Schedule.order(scheduled_time: :desc)
  end

  def delete_schedules
    if params[:schedule_id].present?
      schedule_id = params[:schedule_id].to_i
      schedule = User::Schedule.find_by(id: schedule_id)
      Rails.logger.info "Attempting to delete schedule with ID: #{schedule_id}"
      if schedule
        Rails.logger.info "Schedule found: #{schedule.inspect}"
        schedule.destroy
        job = Sidekiq::ScheduledSet.new.find { |j| j.jid == schedule.job_id }
        if job
          Rails.logger.info "Found Sidekiq job: #{job.inspect}"
          job.delete
        else
          Rails.logger.warn "Sidekiq job not found for schedule ID: #{schedule.id}"
        end
        render json: { redirect_url: admin_all_schedules_path }, status: :ok
      else
        format.html { render action: 'all_schedules', alert: I18n.t('Notify.Note.Delete_Message_Fail') }
      end
    else
      format.html { render action: 'all_schedules', alert: I18n.t('Notify.Note.Delete_Message_Fail') }
    end
  end

  # 取得同社區可設定為被照顧者的使用者
  def cared_candidates
    community_id = params[:community_id]
    caregiver_id = params[:id]
    Rails.logger.info "Found community_id : #{community_id}"

    # 取得所有符合條件的使用者
    users = User.where(community_id: community_id).where.not(id: caregiver_id)

    # 取得已經被設為被照顧者的使用者 ID
    selected_user_ids = User::UsersReleatedCaregivers.where(caregiver_id: caregiver_id).pluck(:cared_id)

    # 準備結果資料
    result = users.includes(:profile).map do |user|
      {
        id: user.id,
        name: user.name,
        line_name: user.line_name,
        selected: selected_user_ids.include?(user.id)
      }
    end

    render json: result
  end

  # 設定被照顧者
  def set_cared
    caregiver_id = params[:id]
    cared_ids = params[:cared_ids] || []
    # 先移除舊的
    User::UsersReleatedCaregivers.where(caregiver_id: caregiver_id).destroy_all
    # 新增
    cared_ids.each do |cared_id|
      User::UsersReleatedCaregivers.create(caregiver_id: caregiver_id, cared_id: cared_id)
    end
    render json: { status: 'success' }
  rescue StandardError => e
    render json: { status: 'fail', message: e.message }
  end

  private

  def set_user
    @user = User.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    params.require(:user).permit!
  end

  def set_breadcrumb
    @title = I18n.t('Title.USERS')
    @title_sub = nil
  end
end
