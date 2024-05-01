# -*- encoding : utf-8 -*-
class Web::RequestsController < ApplicationWebController

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @Requests = Request.all
    end
  
    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @Request = Request.new()
      respond_to do |format|
        format.html
      end
    end
  
    def create
      @title_sub = I18n.t(:New, scope: "Title")
      @Request = Request.new(Request_params)
      respond_to do |format|
        if @Request.save
          format.html { redirect_to Request_Requests_path, notice: I18n.t(:Created, scope: "Notice", name: "#{@Request.account}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{@Request.account}") }
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
      if current_Request.super_Request == false
        result = @Request.update_without_password(Request_params)
      else
        if params[:Request][:password].present?
          result = @Request.update(Request_params)
        else
          result = @Request.update_without_password(Request_params)     
        end
      end
  
      respond_to do |format|
        if result
          format.html { redirect_to Request_Requests_path, notice: I18n.t(:Updated, scope: "Notice", name: "#{@Request.account}") }
        else
          format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@Request.account}") }
        end
      end
  
    end
  
    def destroy
      respond_to do |format|
        if @Request.super_Request == true
          format.html { redirect_back fallback_location: "/", alert: I18n.t(:Cannot_Del_Super, scope: "Notice") }
        elsif current_Request.super_Request != true
          format.html { redirect_back fallback_location: "/" , alert: I18n.t(:Non_Super_Del_Request, scope: "Notice") }
        else
          if @Request.destroy
            format.html { redirect_to Request_Requests_path, notice: I18n.t(:Deleted, scope: "Notice", name: "#{@Request.account}") }
          else
            format.html { redirect_back fallback_location: "/", alert: I18n.t(:Deleted_Fail, scope: "Notice", name: "#{@Request.account}") }
          end
        end
      end
    end
  
    private
  
    def set_Request
      @Request = Request.find_by_id(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def Request_params
      params.require(:Request).permit!
    end
  
  
    def set_breadcrumb
      @title = I18n.t(:RequestISTRATORS, scope: "Title")
      @title_sub = nil
    end
  
  end
  