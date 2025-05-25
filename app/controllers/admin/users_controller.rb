class Admin::UsersController < ApplicationAdminController
  include LineHelper
  include ApplicationHelper
  before_action :set_user, except: %i[index new create all_schedules delete_schedules]
  before_action :ensure_user, only: %i[edit show update block]

  def index
    @title_sub = I18n.t('Title.Table')
    # 超級管理者可查看所有使用者，一般管理者只能查看同社區使用者
    @users = if current_admin.super_admin?
               User.all.order(id: :desc)
             else
               Rails.logger.info "Found current_admin.community_id : #{current_admin.community_id}"
               User.where(community_id: current_admin.community_id).order(id: :desc)
             end
  end

  def new
    @title_sub = I18n.t('Title.New')
    @user = User.new
    # 如果是一般管理者，預設社區ID為管理者的社區ID
    @user.community_id = current_admin.community_id unless current_admin.super_admin?
    # 獲取可選的社區列表，超級管理者可選所有社區，一般管理者只能選自己的社區
    @communities = if current_admin.super_admin?
                     Community.all.sorted
                   else
                     Community.where(id: current_admin.community_id).sorted
                   end
    respond_to do |format|
      format.html
    end
  end

  def create
    # 檢查此社區是否已經有相同身份證的使用者
    existing_user = if current_admin.super_admin? && params[:user][:community_id].present?
                      User.where(id_card: params[:user][:id_card], community_id: params[:user][:community_id]).first
                    else
                      User.where(id_card: params[:user][:id_card], community_id: current_admin.community_id).first
                    end

    if existing_user
      @communities = if current_admin.super_admin?
                       Community.all.sorted
                     else
                       Community.where(id: current_admin.community_id).sorted
                     end
      respond_to do |format|
        format.html do
          @user = User.new(admin_params)
          flash.now[:alert] = I18n.t('Notify.Note.ID_Card_Exists', id_card: params[:user][:id_card])
          render action: 'new'
        end
      end
      return
    end

    @title_sub = I18n.t('Title.New')
    @user = User.new(admin_params) # 如果是一般管理者，強制設定社區ID為管理者的社區ID
    @user.community_id = current_admin.community_id unless current_admin.super_admin?

    # 為新建使用者設置預設帳號（身份證）和其他必要欄位
    @user.account = Time.current.strftime('%y%m%d%H%M%S%L')
    @user.comment = "建立者ID：#{current_admin.id}，建立者名稱：#{current_admin.name}"
    @user.note = 'no_line'
    @user.current_sign_in_at = Time.current
    @user.last_sign_in_at = Time.current
    # 設置使用者狀態為啟用
    @user.enable = true
    @user.is_accepted = true

    # 建立與使用者關聯的資料檔案 (profile)
    @user_profile = User::Profile.new
    # @user_profile.user = @user
    # 預設值設定
    @user_profile.line_name = @user.name
    @user_profile.line_uid = @user.account
    @user_profile.line_image = ActionController::Base.helpers.asset_path('valex/img/faces/no_line.png')
    @user_profile.line_token = ''
    # 保存使用者資料的關聯檔案
    @user.profile = @user_profile

    respond_to do |format|
      if @user.save
        format.html do
          redirect_to admin_users_path, notice: I18n.t('Notify.Note.Account_Created', name: "#{@user.name}")
        end
      else
        # 如果保存失敗，重新獲取社區列表
        @communities = if current_admin.super_admin?
                         Community.all.sorted
                       else
                         Community.where(id: current_admin.community_id).sorted
                       end
        format.html do
          render action: 'new', alert: I18n.t('Notify.Note.Account_Created_Fail', name: "#{@user.name}")
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

    # 如果不是超級管理者且嘗試編輯其他社區的使用者，重定向到使用者列表
    unless current_admin.super_admin? || @user.community_id == current_admin.community_id
      redirect_to admin_users_path, alert: I18n.t('Notify.Note.Cannot_Edit_Other_Community')
      return
    end

    # 獲取可選的社區列表
    @communities = if current_admin.super_admin?
                     Community.all.sorted
                   else
                     Community.where(id: current_admin.community_id).sorted
                   end
  end

  def update
    @title_sub = I18n.t('Title.Edit')

    # 檢查身份證是否重複
    if id_card_changed_and_duplicate?
      handle_duplicate_id_card
      return
    end

    update_params = prepare_update_params
    result = update_user(update_params)

    respond_to do |format|
      if result
        handle_successful_update(format)
      else
        handle_failed_update(format)
      end
    end
  end

  def id_card_changed_and_duplicate?
    return false unless params[:user][:id_card].present? && params[:user][:id_card] != @user.id_card

    community_id = current_admin.super_admin? ? params[:user][:community_id] : current_admin.community_id
    User.where(id_card: params[:user][:id_card], community_id: community_id)
        .where.not(id: @user.id).exists?
  end

  def handle_duplicate_id_card
    @communities = get_available_communities
    respond_to do |format|
      format.html do
        flash.now[:alert] = I18n.t('Notify.Note.ID_Card_Exists', id_card: params[:user][:id_card])
        render action: 'edit'
      end
    end
  end

  def prepare_update_params
    update_params = admin_params.dup
    unless current_admin.super_admin?
      # 檢查是否嘗試修改社區ID
      if update_params[:community_id].present? && update_params[:community_id].to_i != current_admin.community_id
        respond_to do |format|
          format.html do
            redirect_to admin_users_path, alert: I18n.t('Notify.Note.Cannot_Update_Other_Community')
          end
        end
        return nil
      end
      # 確保社區ID不變
      update_params[:community_id] = @user.community_id
    end
    update_params
  end

  def update_user(update_params)
    return nil unless update_params

    if params[:user][:account].present?
      @user.update(update_params)
    else
      @user.update_without_password(update_params)
    end
  end

  def handle_successful_update(format)
    add_log(ACTION_EDIT, LOG_ADMIN, current_admin.id, LOG_USER, @user.id)
    append_user(format('%010d', @user.id), @user.id_card)
    format.html do
      redirect_to admin_users_path, notice: I18n.t('Notify.Note.Account_Updated', name: @user.line_name.to_s)
    end
  end

  def handle_failed_update(format)
    @communities = get_available_communities
    format.html do
      render action: 'edit', alert: I18n.t('Notify.Note.Account_Updated_Fail', name: @user.line_name.to_s)
    end
  end

  def get_available_communities
    if current_admin.super_admin?
      Community.all.sorted
    else
      Community.where(id: current_admin.community_id).sorted
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

  def ensure_user
    unless @user
      begin
        redirect_to admin_users_path, alert: I18n.t('Notify.Note.User_Not_Found')
      rescue StandardError
        '使用者不存在'
      end
      return false
    end
    true
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    # 先允許所有參數，然後才能進行處理
    user_params = params.require(:user).permit!

    # 將許可後的參數轉換為 hash
    user_hash = user_params.to_h

    # 處理字串參數，去除前後空白
    sanitized_hash = {}
    user_hash.each do |key, value|
      sanitized_hash[key] = if value.is_a?(String) && !value.blank?
                              value.strip
                            else
                              value
                            end
    end

    # 回傳處理後的參數
    ActionController::Parameters.new(sanitized_hash).permit!
  end

  def set_breadcrumb
    @title = I18n.t('Title.USERS')
    @title_sub = nil
  end
end
