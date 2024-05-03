# -*- encoding : utf-8 -*-
class Web::UserController < ApplicationWebController
    before_action :set_user, only: [:show, :edit, :update]

    def show
        @title_sub = I18n.t(:Information, scope: "Title")
        respond_to do |format|
            format.html
        end
    end

    def edit
        @title_sub = I18n.t(:Edit, scope: "Title")
    end

    def update
        @title_sub = I18n.t(:Edit, scope: "Title")
        result = @user.update_without_password(user_params)

        respond_to do |format|
            if result
                format.html { redirect_to admin_admins_path, notice: I18n.t(:Updated, scope: "Notice", name: "#{@admin.account}") }
            else
                format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@admin.account}") }
            end
        end
    end

    def line_notify_index
        @title_sub = I18n.t(:LINE_NOTIFY, scope: "Notify.Title")
        @user = current_user
        @services = current_customer.line_notify_services
        token = current_user.notify_token
        if !token.nil? && is_token_valid(token) == false
            token.destroy
        end
    end

    self.request_forgery_protection_token = :state

    def valid_request_origin?
        if forgery_protection_origin_check
            # We accept blank origin headers because some user agents don't send it.
            request.origin.nil? || request.origin == "null" || request.origin == request.base_url
        else
            true
        end
    end

    # post create
    def line_notify_authorize
        service = current_customer.line_notify_services.find_by_id(params[:server_id])
        if service == nil || service.client_id == "" || service.client_secret == ""
            result = false
        else
            client_id = service.client_id
            client_secret = service.client_secret
            customer = current_user.customer
            forward_url = customer.weburl
            if forward_url != "" && forward_url != nil
                callback = "#{forward_url}/line_notify/callback/"
            else
                callback = "#{customer.account}/line_notify/callback/"
            end
            auth_url = authorize(callback,client_id,client_secret)

            if !current_user.notify_token.nil?
                delete_token(current_user.notify_token)
            end

            result = current_user.create_line_notify_token(line_notify_service_id: service.id)
        end

        respond_to do |format|
            if result
                format.html { redirect_to auth_url }
            else
                format.html { redirect_to user_school_line_notify_index_path, notice: "some thing error!! Please try again!!" }
            end
        end
    end

    def line_notify_revoke
        service = current_customer.line_notify_services.find_by_id(params[:server_id])
        if service == nil
            result = false
        else
            if current_user.notify_token.nil?
                result = false
            else
                result = delete_token(current_user.notify_token)
            end
        end

        respond_to do |format|
            if result
                format.html { redirect_to user_school_line_notify_index_path, notice: "Success Unconnect Line Notify!!" }
            else
                format.html { redirect_to user_school_line_notify_index_path, alert: "Token does not exist!!" }
            end
        end
    end

    def line_notify_callback
        current_token = current_user.notify_token
        client_id = current_token.client_id
        client_secret = current_token.client_secret
        customer = current_user.customer
        forward_url = customer.weburl
        if forward_url != "" && forward_url != nil
            callback = "#{forward_url}/line_notify/callback/"
        else
            callback = "#{customer.account}/line_notify/callback/"
        end
        token = get_token(callback,client_id,client_secret,params[:code])

        respond_to do |format|
            if token.params["status"] == 200
                current_token.update(token: token.token)
                format.html { redirect_to user_school_line_notify_index_path, notice: "Success Connect Line Notify!!" }
            else
                format.html { redirect_to user_school_line_notify_index_path, alert: "Something Error!! Please Try Again!!" }
            end
        end
    end

    private

    def set_user
        @user = current_user
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
