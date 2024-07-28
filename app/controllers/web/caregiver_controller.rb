# -*- encoding : utf-8 -*-
class Web::CaregiverController < ApplicationWebController
    include LineHelper
    before_action :set_user, only: [:show, :agree, :delete, :cared_delete]
    skip_before_action :verify_authenticity_token, only: [:delete, :cared_delete]

    def show
        @cared = User.find(params[:id])
        @user_cared = @user.careds.first
    end

    def agree
        @cared = User.find(params[:id])
        respond_to do |format|
            if @cared.id == @user.id
                format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.Something_Wrong") }
            else
                if User::UsersReleatedCaregivers.create(cared_id: @cared.id, caregiver_id: @user.id)
                    message_push(@cared.account, "Hi , #{@user.name}同意成為你的照護者")
                    @cared.add_each_friends(@user.id)
                    format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.You_accept_this_caregiver", name: "#{@cared.name}") }
                else
                    format.html { redirect_to web_accept_edit_path, notice: I18n.t("Notify.Note.Something_Wrong") }
                end
            end
        end
    end

    def delete
        @caregiver = User.find(params[:caregiver_id])
        if !@caregiver.nil?
            User::UsersReleatedCaregivers.where(cared_id: @user.id, caregiver_id: @caregiver.id).destroy_all
        end
        redirect_to web_user_edit_path, notice: I18n.t("Notify.Note.You_remove_this_caregiver")
    end

    def cared_delete
        @cared = User.find(params[:cared_id])
        puts "AAAAA"
        puts @cared.id
        puts @user.id
        if !@cared.nil?
            User::UsersReleatedCaregivers.where(cared_id: @cared.id, caregiver_id: @user.id).destroy_all
        end
        redirect_to web_user_edit_path, notice: I18n.t("Notify.Note.You_remove_this_caregiver")
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
