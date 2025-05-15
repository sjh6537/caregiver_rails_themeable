class Web::UserController < ApplicationWebController
  include ApplicationHelper
  before_action :set_user
  before_action :check_user_accepted, only: %i[show health_report fitness_report edit careds]

  def show
    @careds = @user.careds
    @caregivers = @user.caregivers
    return if params[:notice].nil?

    # redirect_to web_user_show_path, notice: params[:notice]
    redirect_to web_user_show_path
  end

  def health_report
    @reports = @user.health_reports.order(id: :desc)
    @title_sub = I18n.t(:HEALTH_REPORT, scope: 'Title')
  end

  def fitness_report
    @reports = @user.fitness_reports.order(id: :desc)
    @title_sub = I18n.t(:FITNESS_REPORT, scope: 'Title')
  end

  def agreement
    @title_sub = I18n.t(:AGREEMENT, scope: 'Title')
  end

  def accept_agreement
    if @user.update(is_accepted: true)
      redirect_to web_user_edit_path
    else
      redirect_to web_user_agreement_path
    end
  end

  def edit
    # redirect_to web_user_agreement_path if !@user.id_card.present?
    @title_sub = I18n.t(:Edit, scope: 'Title')
    @community = @user.community
  end

  def update
    @title_sub = I18n.t(:Update, scope: 'Title')
    result = @user.update(user_params)

    respond_to do |format|
      if result
        append_user('%010d' % @user.id , @user.id_card)
        format.html do
          redirect_to web_user_show_path, notice: I18n.t('Website.Note.Update_Success', name: "#{@user.line_name}")
        end
      else
        format.html do
          render action: 'edit', alert: I18n.t('Website.Note.Update_Fail', name: "#{@user.line_name}")
        end
      end
    end
  end

  def friends
  end

  def requests
  end

  def coupons
    @page = params[:page]
    @user_coupons = @user.coupons
    @shops = Shop.all
  end

  def coins
    @history_coins = @user.history_coins
  end

  # 新增 careds 動作
  def careds
    @careds = @user.careds
    @title_sub = I18n.t(:CARE_RECEIVER, scope: 'Title')
  end

  def careds_new
    @cared_user = User.new
    @title_sub = I18n.t(:CARE_RECEIVER, scope: 'Title')
    render view: 'careds'
  end

  # 前台建立被照護者
  def create_cared
    @cared_user = User.new(user_params)
    @cared_user.account = Time.current.strftime('%y%m%d%H%M%S%L')
    @cared_user.enable = true
    @cared_user.is_accepted = true
    @cared_user.note = "建立者ID：#{@user.id}，建立者名稱：#{@user.name}"
    @cared_user.community_id = @user.community_id
    @cared_user.current_sign_in_at = Time.current
    @cared_user.last_sign_in_at = Time.current

    # 驗證同社區身份證重複
    existing_user = User.find_by(id_card: @cared_user.id_card, community_id: @user.community_id)
    # 若身份證已存在，直接綁定關聯
    if existing_user.present? && !User::UsersReleatedCaregivers.exists?(caregiver_id: @user.id,
                                                                        cared_id: existing_user.id)
      User::UsersReleatedCaregivers.create(caregiver_id: @user.id, cared_id: existing_user.id)
      redirect_to web_user_careds_path,
                  notice: I18n.t('Notify.Note.Cared_Connected',
                                 name: existing_user.name || existing_user.line_name)
    end

    # 建立 profile
    @cared_user.build_profile(line_name: @cared_user.name, line_uid: @cared_user.account,
                              line_image: ActionController::Base.helpers.asset_path('valex/img/faces/no_line.png'), line_token: '')

    if @cared_user.save
      # 綁定關聯
      User::UsersReleatedCaregivers.create(caregiver_id: @user.id, cared_id: @cared_user.id)
      redirect_to web_user_careds_path, notice: I18n.t('Notify.Note.Cared_Connected', name: @cared_user.name)
    else
      @careds = @user.careds
      @title_sub = I18n.t(:CARE_RECEIVER, scope: 'Title')
      flash.now[:alert] = I18n.t('Notify.Note.Cared_Created_Fail')
      render :careds
    end
  end

  def caregivers
    @caregivers = @user.caregivers
    @title_sub = I18n.t(:CAREGIVER, scope: 'Title')
  end

  # 快速新增被照護者（從模態視窗）
  def add_cared
    # 檢查必要的參數
    # 去除參數前後空白
    params[:name] = params[:name].strip if params[:name].is_a?(String)
    params[:phone] = params[:phone].strip if params[:phone].is_a?(String)
    params[:id_card] = params[:id_card].strip if params[:id_card].is_a?(String)

    unless params[:name].present? && params[:phone].present? && params[:id_card].present?
      redirect_to web_user_careds_path, alert: '請填寫必要的資訊'
      return
    end

    # 檢查是否已存在相同手機號碼的使用者（在同社區）
    existing_user = User.find_by(id_card: params[:id_card], community_id: @user.community_id)

    if existing_user.present?
      # 檢查是否已經是照護關係
      if User::UsersReleatedCaregivers.exists?(caregiver_id: @user.id, cared_id: existing_user.id)
        redirect_to web_user_careds_path, alert: '此使用者已經在您的被照護者名單中'
        return
      end

      # 新增照護關係
      User::UsersReleatedCaregivers.create(caregiver_id: @user.id, cared_id: existing_user.id)
      redirect_to web_user_careds_path, notice: "已成功加入 #{existing_user.name} 至您的照護名單"
      return
    end

    # 建立新使用者
    new_cared = User.new(
      name: params[:name],
      phone: params[:phone],
      id_card: params[:id_card],
      account: Time.current.strftime('%y%m%d%H%M%S%L'),
      enable: true,
      is_accepted: true,
      note: "建立者ID：#{@user.id}，建立者名稱：#{@user.name}，關係：#{params[:relationship]}",
      community_id: @user.community_id,
      current_sign_in_at: Time.current,
      last_sign_in_at: Time.current
    )

    # 建立 profile
    new_cared.build_profile(
      line_name: params[:name],
      line_uid: new_cared.account,
      line_image: ActionController::Base.helpers.asset_path('valex/img/faces/no_line.png'),
      line_token: ''
    )

    if new_cared.save
      # 綁定關聯
      User::UsersReleatedCaregivers.create(caregiver_id: @user.id, cared_id: new_cared.id)
      redirect_to web_user_careds_path, notice: "已成功建立並加入 #{new_cared.name} 至您的照護名單"
    else
      redirect_to web_user_careds_path, alert: '建立失敗，請檢查輸入的資訊'
    end
  end

  private

  def set_user
    @user = current_user
    @profile = @user.profile if @user.present?
  end

  def check_user_accepted
    return if @user.is_accepted

    # params[:notice] = nil
    redirect_to web_user_agreement_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
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
    @title = I18n.t(:PERSONAL, scope: 'User.Title')
    @title_sub = nil
  end
end
