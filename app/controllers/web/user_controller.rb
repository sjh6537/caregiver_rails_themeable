class Web::UserController < ApplicationWebController
  include ApplicationHelper
  before_action :set_user
  before_action :check_user_accepted, only: %i[show health_report fitness_report edit careds]

  def show
    @cared = @user.careds.first
    @caregiver = @user.caregivers.first
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
    @title_sub = I18n.t(:CAREDS, scope: 'Title') # 假設翻譯檔案中有此鍵值
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
