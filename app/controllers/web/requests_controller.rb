# -*- encoding : utf-8 -*-
class Web::RequestsController < ApplicationWebController
    before_action :set_user
    before_action :set_request, only: [:friends, :pushed, :shared, :show, :destroy]

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @Requests = @user.requests
    end

    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @category = params[:category].to_i
      if @category == 0 || @category == 8
        title="請幫忙"
      else
        title="有#{REQUEST_CATEGORY[@category]}方面的事需要幫忙"
      end
      @descrition = "Hi, 需要你的幫忙\r\n"
      @request = @user.requests.new(category: params[:category], title: title, location: @user.address, location_city: @user.addr_city, location_postal: @user.addr_postal, contact_info: @user.phone)
      respond_to do |format|
        format.html
      end
    end

    def create
      @title_sub = I18n.t(:Friends, scope: "Title")
      @request = @user.requests.new(request_params)
      respond_to do |format|
        if @request.save
          format.html { redirect_to web_request_friends_path(@request.id), notice: I18n.t(:Created, scope: "Notice", name: "#{@user.name}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{@user.name}") }
        end
      end
    end

    def friends
      @friends = @user.friends
      @receiver = User::RequestReceiver.new
    end

    def pushed
      fails_ids = []
      ids = params.require(:user_request_receiver).permit!
      ids[:user_id].each do |id|

        receiver = User::RequestReceiver.where(request_id: @request.id, receiver_id: id).first
        if receiver.nil?
          receiver = User::RequestReceiver.new
          receiver.receiver_id = id
          receiver.request_id = @request.id
          receiver.count = 1
          if !receiver.save
            fails_ids << id
          end
        else
          if !receiver.update(count: receiver.count+1)
            fails_ids << id
          end
        end
      end

      @request_receivers = @request.request_receivers
    end

    def shared

    end

    def show
      @request_receivers = @request.request_receivers
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
      @request = User::Request.find_by_id(params[:id])
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
