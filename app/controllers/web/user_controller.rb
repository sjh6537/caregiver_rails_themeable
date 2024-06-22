# -*- encoding : utf-8 -*-
class Web::UserController < ApplicationWebController
    include ApplicationHelper
    before_action :set_user

    def show
        if params[:notice] != nil
            redirect_to web_user_show_path, notice: params[:notice]
        end
    end

    def edit
        @title_sub = I18n.t(:Edit, scope: "Title")
    end

    def update
        @title_sub = I18n.t(:Update, scope: "Title")
        result = @user.update(user_params)

        respond_to do |format|
            if result
                append_user(@user.account,@user.phone)
                format.html { redirect_to web_user_show_path, notice: I18n.t("Website.Note.Update_Success", name: "#{@user.line_name}") }
            else
                format.html { render action: "edit", alert: I18n.t("Website.Note.Update_Fail", name: "#{@user.line_name}") }
            end
        end
    end

    def friends

    end

    def requests

    end

    def coupons
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
        @title = I18n.t(:PERSONAL, scope: "User.Title")
        @title_sub = nil
    end

end
