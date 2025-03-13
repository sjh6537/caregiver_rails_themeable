module Web
  class RequestsController < ApplicationWebController
    include LineHelper

    before_action :set_user
    before_action :set_request, only: %i[friends pushed shared agree show destroy]

    def index
      @title_sub = I18n.t(:Table, scope: 'Title')
      @Requests = @user.requests
    end

    def new
      @title_sub = I18n.t(:New, scope: 'Title')
      @category = params[:category].to_i
      title = if @category.zero?
                '請幫忙'
              else
                "請幫忙#{request_category_text(@category)}"
              end
      @descrition = "Hi, 需要你的幫忙\r\n"
      @request = @user.requests.new(descrition: @descrition, category: params[:category], title: title,
                                    location: @user.address, location_city: @user.addr_city, location_postal: @user.addr_postal, contact_info: @user.phone)
      respond_to(&:html)
    end

    def create
      @title_sub = I18n.t(:Friends, scope: 'Title')
      @request = @user.requests.new(request_params)
      @category = @request.category
      respond_to do |format|
        if @request.save
          format.html do
            redirect_to web_request_friends_path(@request.id), notice: I18n.t('Notify.Note.Your_request_already_create')
          end
        else
          format.html { render action: 'new', notice: I18n.t(:Created, scope: 'Notice', name: @user.name.to_s) }
        end
      end
    end

    def friends
      @friends = @user.friends
      @caregiver = @user.caregivers.first
      @receiver = User::RequestReceiver.new
    end

    def pushed
      if params[:user_request_receiver].nil?
        @request_receivers = nil
      else
        fails_ids = []
        ids = params.require(:user_request_receiver).permit!
        ids[:user_id].each do |id|
          receiver = User::RequestReceiver.where(request_id: @request.id, receiver_id: id).first
          if receiver.nil?
            receiver = User::RequestReceiver.new
            receiver.receiver_id = id
            receiver.request_id = @request.id
            receiver.count = 1
            fails_ids << id unless receiver.save
          else
            fails_ids << id unless receiver.update(count: receiver.count + 1)
          end
          push_request_message(@request , User.find(id))
        end

        @request_receivers = @request.request_receivers
      end
    end

    def shared; end

    def agree
      respond_to do |format|
        if @request.update(helper_id: @user.id, status: REQUEST_ACCEPTED)
          @request.owner.add_each_friends(@user.id)
          format.html do
            redirect_to web_user_show_path,
                        notice: I18n.t('Notify.Note.You_accept_this_request', name: @request.owner.name.to_s)
          end
        else
          format.html { redirect_to web_request_show_path(@request.id), alert: I18n.t('Notify.Note.Something_Wrong') }
        end
      end
    end

    def show
      @request_receivers = @request.request_receivers
      return if params[:notice].nil?

      redirect_to web_request_show_path(@request.id), notice: params[:notice]
    end

    def destroy
      respond_to do |format|
        if @request.super_request == true
          format.html { redirect_back fallback_location: '/', alert: I18n.t(:Cannot_Del_Super, scope: 'Notice') }
        elsif current_request.super_Request != true
          format.html { redirect_back fallback_location: '/' , alert: I18n.t(:Non_Super_Del_Request, scope: 'Notice') }
        elsif @request.destroy
          format.html do
            redirect_to Request_Requests_path, notice: I18n.t(:Deleted, scope: 'Notice', name: @request.account.to_s)
          end
        else
          format.html do
            redirect_back fallback_location: '/',
                          alert: I18n.t(:Deleted_Fail, scope: 'Notice',
                                                       name: @request.account.to_s)
          end
        end
      end
    end

    private

    def push_request_message(request , friend)
      return if friend.nil? || request.nil?

      text = "Hi , #{friend.name} , 你的朋友 #{current_user.name} 需要你的幫忙\"#{request.title}\" , 點選下列網址查看細節幫助朋友\r\n"
      text += " #{APP_CONFIG[:line_liff_url]}/requests/#{request.id}"
      message_push(friend.account, text)
    end

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
      @title = I18n.t(:RequestISTRATORS, scope: 'Title')
      @title_sub = nil
    end
  end
end
