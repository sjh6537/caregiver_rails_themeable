# -*- encoding : utf-8 -*-
class Web::HealthController < ApplicationWebController
    before_action :set_user, only: [:edit, :update, :go]

    def edit
        if !@user.name.nil? && @user.phone != ""
            redirect_to web_health_go_path
        end
    end

    def update
        result = @user.update(user_params)
        if result
            redirect_to web_health_go_path
        else
            render action: "edit", alert: I18n.t("Website.Note.Update_Fail", name: "#{@user.line_name}")
        end
    end

    def go
        if @user.name.nil? || @user.phone == ""
            redirect_to web_health_edit_path
        else
            url = "#{APP_CONFIG[:health_view_url]}?MemberId=#{"%010d" % @user.id}&Phone=#{@user.phone}"
            redirect_to url, allow_other_host: true
        end

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

end
