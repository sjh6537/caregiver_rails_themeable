# -*- encoding : utf-8 -*-
class Web::CaregiverController < ApplicationWebController
    before_action :set_user, only: [:show, :agree]

    def show
        @cared = User.find(params[:id])
    end

    def agree
        @cared = User.find(params[:id])
        respond_to do |format|
            if @cared.id == @user.id
                format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.Something_Wrong") }
            else
                if User::UsersReleatedCaregivers.create(cared_id: @cared.id, caregiver_id: @user.id)
                    @cared.add_each_friends(@user.id)
                    format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.You_accept_this_caregiver", name: "#{@cared.name}") }
                else
                    format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.Something_Wrong") }
                end
            end
        end
    end

    private

    def set_user
        @user = current_user
        @profile = @user.profile
    end

    def set_breadcrumb
        @title = I18n.t(:PERSONAL, scope: "User.Title")
        @title_sub = nil
    end

end
