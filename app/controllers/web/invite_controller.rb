# -*- encoding : utf-8 -*-
class Web::InviteController < ApplicationWebController
    before_action :set_user, only: [:edit, :update]

    def edit
        @user.add_each_friends(@friend.id)
        if !(@user.name == "" || @user.addr_city == 0 || @user.addr_postal == 0 || @user.address == "")
            redirect_to web_invite_join_path
        end
    end

    def update
        result = @user.update(user_params)
        if result
            redirect_to web_invite_join_path
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
        @friend = User.find_by_id(params[:friend_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
        params.require(:user).permit!
    end

end
