# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationAdminController
    before_action :set_admin, only: [:show, :edit, :update, :destroy, :push]
  
    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @users = User.all
    end
  
    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @user = User.new()
      respond_to do |format|
        format.html
      end
    end

    def create
      @title_sub = I18n.t(:New, scope: "Title")
      @user = User.new(admin_params)
      respond_to do |format|
        if @user.save
          format.html { redirect_to admin_users_path, notice: I18n.t(:Created, scope: "Notice", name: "#{@user.account}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{@user.account}") }
        end
      end
    end
  
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
          format.html { redirect_to admin_users_path, notice: I18n.t(:Updated, scope: "Notice", name: "#{@user.account}") }
        else
          format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@user.account}") }
        end
      end
  
    end
  
    def destroy
      respond_to do |format|
        # if @user.super_user == true
        #   format.html { redirect_back fallback_location: "/", alert: I18n.t(:Cannot_Del_Super, scope: "Notice") }
        # elsif current_admin.super_user != true
        #   format.html { redirect_back fallback_location: "/" , alert: I18n.t(:Non_Super_Del_Admin, scope: "Notice") }
        # else
          if @user.destroy
            format.html { redirect_to admin_users_path, notice: I18n.t(:Deleted, scope: "Notice", name: "#{@user.account}") }
          else
            format.html { redirect_back fallback_location: "/", alert: I18n.t(:Deleted_Fail, scope: "Notice", name: "#{@user.account}") }
          end
        # end
      end
    end

    def push

    end

    private
  
    def set_admin
      @user = User.find_by_id(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.require(:user).permit!
    end
  
    def set_breadcrumb
      @title = I18n.t(:ADMINISTRATORS, scope: "Title")
      @title_sub = nil
    end
end
  