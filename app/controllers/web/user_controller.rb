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
    @caregiver = @user.caregivers.first
    @cared = @user.careds.first
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

  # 前台建立被照護者
  def create_cared
    @cared_user = User.new(user_params)
    @cared_user.account = Time.current.strftime('%y%m%d%H%M%S%L')
    @cared_user.enable = true
    @cared_user.is_accepted = true
    @cared_user.note = 'created_by_caregiver'
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
      flash.now[:alert] = I18n.t('Notify.Note.Account_Created_Fail', name: @cared_user.name)
      render :careds
    end
  end

  def caregivers
    @caregivers = @user.caregivers
    @title_sub = I18n.t(:CAREGIVER, scope: 'Title')
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
    params.require(:user).permit!
  end

  def set_breadcrumb
    @title = I18n.t(:PERSONAL, scope: 'User.Title')
    @title_sub = nil
  end
end
