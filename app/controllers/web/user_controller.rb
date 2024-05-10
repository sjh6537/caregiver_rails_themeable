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
        @title_sub = I18n.t(:Update, scope: "Title")
        result = @user.update(user_params)

        respond_to do |format|
            if result
                format.html { redirect_to web_user_show_path, notice: I18n.t(:Updated, scope: "Notice", name: "#{@user.line_name}") }
            else
                format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@user.line_name}") }
            end
        end
    end

end
