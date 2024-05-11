# -*- encoding : utf-8 -*-
class Web::RequestsController < ApplicationWebController
    before_action :set_user
    before_action :set_request, only: [:show, :destroy]

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @Requests = current_user.requests
    end

    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @category = params[:category].to_i
      if @category == 0 || @category == 8
        title="請幫忙"
      else
        title="有#{REQUEST_CATEGORY[@category]}方面的事需要幫忙"
      end
      contact_info="請用電話聯絡"
      @descrition = "Hi, 需要你的幫忙\r\n"
      @descrition+= "內容為 :\r\n"
      @request = current_user.requests.new(category: params[:category], title: title, location: current_user.address_text, contact_info: contact_info)
      respond_to do |format|
        format.html
      end
    end

    def create
      @title_sub = I18n.t(:Friends, scope: "Title")
      @request = current_user.requests.new(request_params)
      respond_to do |format|
        if @request.save
          format.html { redirect_to Request_Requests_path, notice: I18n.t(:Created, scope: "Notice", name: "#{current_user.name}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{current_user.name}") }
        end
      end
    end

    def friends


    end

    def show
      @title_sub = I18n.t(:Information, scope: "Title")
      respond_to do |format|
        format.html
      end
    end

    def destroy
      respond_to do |format|
        if @request.super_request == true
          format.html { redirect_back fallback_location: "/", alert: I18n.t(:Cannot_Del_Super, scope: "Notice") }
        elsif current_request.super_Request != true
          format.html { redirect_back fallback_location: "/" , alert: I18n.t(:Non_Super_Del_Request, scope: "Notice") }
        else
          if @request.destroy
            format.html { redirect_to Request_Requests_path, notice: I18n.t(:Deleted, scope: "Notice", name: "#{@Request.account}") }
          else
            format.html { redirect_back fallback_location: "/", alert: I18n.t(:Deleted_Fail, scope: "Notice", name: "#{@Request.account}") }
          end
        end
      end
    end

    private
    def set_user
      @user = current_user
    end

    def set_request
      @request = UserRequest.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.require(:user_request).permit!
    end


    def set_breadcrumb
      @title = I18n.t(:RequestISTRATORS, scope: "Title")
      @title_sub = nil
    end

  end
