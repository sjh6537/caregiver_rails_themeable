module Web
  class UserController < ApplicationWebController
    include ApplicationHelper
    before_action :set_user

    def show
      redirect_to web_user_agreement_path unless @user.id_card.present?
      @cared = @user.careds.first
      @caregiver = @user.caregivers.first
      return if params[:notice].nil?

      # redirect_to web_user_show_path, notice: params[:notice]
      redirect_to web_user_show_path
    end

    def report
      redirect_to web_user_agreement_path unless @user.id_card.present?
      @reports = @user.health_reports.order(id: :desc)
      @title_sub = I18n.t(:HEALTH_REPORT, scope: 'Title')
    end

    def agreement
      redirect_to web_user_edit_path if @user.id_card.present?
      @title_sub = I18n.t(:AGREEMENT, scope: 'Title')
    end

    def edit
      # redirect_to web_user_agreement_path if !@user.id_card.present?
      @title_sub = I18n.t(:Edit, scope: 'Title')
      @caregiver = @user.caregivers.first
      @cared = @user.careds.first
    end

    def update
      @title_sub = I18n.t(:Update, scope: 'Title')
      result = @user.update(user_params)

      respond_to do |format|
        if result
          append_user('%010d' % @user.id , @user.id_card)
          format.html do
            redirect_to web_user_show_path, notice: I18n.t('Website.Note.Update_Success', name: @user.line_name.to_s)
          end
        else
          format.html do
            render action: 'edit', alert: I18n.t('Website.Note.Update_Fail', name: @user.line_name.to_s)
          end
        end
      end
    end

    def friends; end

    def requests; end

    def coupons
      @page = params[:page]
      @user_coupons = @user.coupons
      @shops = Shop.all
    end

    def coins
      @history_coins = @user.history_coins
    end

    private

    def set_user
      @user = current_user
      @profile = @user.profile
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
end
