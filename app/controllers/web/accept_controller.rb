# -*- encoding : utf-8 -*-
class Web::AcceptController < ApplicationWebController
    before_action :set_request, only: [:show, :agree]
    before_action :set_user, only: [:edit, :update, :agree, :show]

    def show
        @request_receivers = @request.request_receivers
    end

    def agree
        respond_to do |format|
            if @request.update(helper_id: @user.id, status: REQUEST_ACCEPTED)
                @request.owner.add_friend(@user.id)
                format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.You_accept_this_request", name: "#{@request.owner.name}") }
            else
                format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.Something_Wrong") }
            end
        end
    end

    def edit
        if !(@user.name == "" || @user.addr_city == 0 || @user.addr_postal == 0 || @user.address == "")
            redirect_to web_accept_join_path
        end
    end

    def update
        result = @user.update(user_params)
        if result
            redirect_to web_accept_join_path
        else
            render action: "edit", alert: I18n.t("Website.Note.Update_Fail", name: "#{@user.line_name}")
        end
    end

    def join
        redirect_to APP_CONFIG[:line_at_url], allow_other_host: true
    end

    private

    def set_user
        @user = current_user
        @profile = @user.profile
    end

    def set_request
        @request = User::Request.find_by_id(params[:id])
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
