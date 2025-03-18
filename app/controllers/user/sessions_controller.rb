class User::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  include LineHelper
  # include Devise::Controllers::Rememberable

  def destroy
    session[:need_return_to] = false
    session[:return_to] = ''
    session[:community_id] = nil
    cookies[:return_to] = ''
    super
  end

  def new
    session[:state] = form_authenticity_token
    community_profile = current_community.profile
    auth_url = login_authorize(community_profile.line_login_callback_url, community_profile.line_login_channel_id,
                               community_profile.line_login_channel_secret, session[:state])
    redirect_to auth_url, allow_other_host: true
  end

  def line_authorize
    session[:state] = form_authenticity_token
    community_profile = current_community.profile
    auth_url = login_authorize(community_profile.line_login_callback_url, community_profile.line_login_channel_id,
                               community_profile.line_login_channel_secret, session[:state])
    redirect_to auth_url, allow_other_host: true
  end

  def line_callback
    # 用於取得存取令牌的授權碼。有效期限10分鐘。此授權碼只能使用一次。
    code = params[:code]

    if params[:state] == session[:state]
      community_profile = current_community.profile
      access_token = login_token(community_profile.line_login_callback_url, community_profile.line_login_channel_id,
                                 community_profile.line_login_channel_secret, code)
      id_token = access_token.params[:id_token]

      response_body = login_get_profile(community_profile.line_login_channel_id,
                                        community_profile.line_login_channel_secret, id_token , access_token)
      uid = JSON.parse(response_body)['sub']
      name = JSON.parse(response_body)['name']
      image = JSON.parse(response_body)['picture']
      email = JSON.parse(response_body)['email']

      @user = User.find_by_account(uid)
      if @user
        # remember_me(@user)
        @user.update(oauth_token: id_token)
        @user.profile.update(line_name: name, line_token: id_token, line_image: image, line_email: email)
      else
        @user = User.new(account: uid, oauth_token: id_token, community_id: current_community.id)
        if @user.save
          @user.create_profile(line_uid: uid, line_name: name, line_token: id_token, line_image: image,
                               line_email: email)
        end
        # redirect_to new_user_registration_url
      end
      sign_in(@user)

      if session[:need_return_to] == true
        url = session[:return_to]
        session[:need_return_to] = false
        session[:return_to] = ''
        cookies[:return_to] = ''
        redirect_to url
      elsif @user.name == '' || @user.addr_city == 0 || @user.addr_postal == 0 || @user.address == ''
        redirect_to web_user_edit_path
      else
        redirect_to web_user_show_path
      end

    else
      redirect_to error_notice_path, notice: 'invalid varification'
    end
  end

  def current_community
    puts 'current_community' + session[:community_id].to_s
    if session[:community].nil?
      redirect_to error_notice_path, notice: 'invalid community'
      return nil
    end

    # 查找實際的 Community 對象而不是使用 session 中的值
    community_id = session[:community_id]
    # 這樣可以避免 session 中的值被修改
    @current_community ||= Community.find_by(id: community_id)

    if @current_community.nil?
      redirect_to error_notice_path, notice: 'community not found'
      return nil
    end

    @current_community
  end
end
