# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationAdminController
    include LineHelper
    before_action :set_user

    def index
        @title_sub = I18n.t("Title.Table")
        @users = User.all
    end

    def new
        @title_sub = I18n.t("Title.New")
        @user = User.new()
        respond_to do |format|
            format.html
        end
    end

    def create
        @title_sub = I18n.t("Title.New")
        @user = User.new(admin_params)
        respond_to do |format|
            if @user.save
                format.html { redirect_to admin_users_path, notice: I18n.t("Notify.Note.Account_Created", name: "#{@user.line_name}") }
            else
                format.html { render action: "new", alert: I18n.t("Notify.Note.Account_Created_Fail", name: "#{@user.line_name}") }
            end
        end
    end

    def show
        @title_sub = I18n.t("Title.Information")
        @history_coins = @user.history_coins
        respond_to do |format|
            format.html
        end
    end

    def edit
        @title_sub = I18n.t("Title.Edit")
    end

    def update
        @title_sub = I18n.t("Title.Edit")
        # if current_admin.super_user == false
        #   result = @user.update_without_password(admin_params)
        # else
        if params[:user][:account].present?
            result = @user.update(admin_params)
        else
            result = @user.update_without_password(admin_params)
        end
        # end

        respond_to do |format|
            if result
                add_log(ACTION_EDIT,LOG_ADMIN,current_admin.id,LOG_USER,@user.id)
                format.html { redirect_to admin_users_path, notice: I18n.t("Notify.Note.Account_Updated", name: "#{@user.line_name}") }
            else
                format.html { render action: "edit", alert: I18n.t("Notify.Note.Account_Updated_Fail", name: "#{@user.line_name}") }
            end
        end

    end

    def block
        respond_to do |format|
            if @user.update(enable: false)
                add_log(ACTION_BLOCK,LOG_ADMIN,current_admin.id,LOG_USER,@user.id)
                format.html { redirect_to admin_users_path, notice: I18n.t("Notify.Note.Account_Blocked", name: "#{@user.line_name}") }
            else
                format.html { redirect_back fallback_location: "/", alert: I18n.t("Notify.Note.Account_Blocked_Fail", name: "#{@user.line_name}") }
            end
        end
    end

    def push

    end

    def send_message
        # type
        # 0: Text message
        # 1: Sticker message
        # 2: Image message
        # 3: Video message
        # 4: Audio message
        # 5: Location message
        # 6: Imagemap message
        # 7: Template message
        # 8: Flex Message
        if params[:text].present? && params[:msgtype].present?
            text = params[:text]
            type = params[:msgtype]

            if params[:id].present? || (params[:id] == "null")
                broadcastEn = 0
            else
                broadcastEn = 1
            end

            lineuser = User.find_by_id(params[:id])
            case type
            when "0"
                message = message_package_text(text)
                if(broadcastEn)
                    message_push(nil, message)
                else
                    message_push(lineuser.account, message)
                end
            end
            render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
            return
        end

        render json: { status: 'error', message: 'Parameter unknown' }, status: :ok
        return
    end

    def coins_deliver
        coins = params[:number].to_i
        @user.profile.update(coins_this_y: @user.profile.coins_this_y + coins)
        @user.history_coins.create(category: COINS_GET_SYSTEM, category_id: current_admin.id, number: coins, description: I18n.t("Notify.Note.Deliver_Coins_Success") )
        add_log(ACTION_ADD,LOG_ADMIN,current_admin.id,LOG_USERCOIN,@user.id,"#{coins}枚")
        redirect_to admin_user_path(@user.id)
    end

    private

    def set_user
        @user = User.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
        params.require(:user).permit!
    end

    def set_breadcrumb
        @title = I18n.t("Title.USERS")
        @title_sub = nil
    end
end
