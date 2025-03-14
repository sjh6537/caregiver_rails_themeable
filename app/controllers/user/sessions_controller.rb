class User::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  include LineHelper
  # include Devise::Controllers::Rememberable

  def destroy
    session[:need_return_to] = false
    session[:return_to] = ''
    cookies[:return_to] = ''
    super
  end

  def new
    community_token = params[:token]
    community_profile = get_community_by_token(community_token)
    session[:state] = form_authenticity_token
    auth_url = login_authorize(community_profile.line_login_callback_url, community_profile.line_login_channel_id,
                               community_profile.line_login_channel_secret, session[:state])
    redirect_to auth_url, allow_other_host: true
  end

  def line_authorize
    community_token = params[:token]
    community_profile = get_community_by_token(community_token)
    session[:state] = form_authenticity_token
    auth_url = login_authorize(community_profile.line_login_callback_url, community_profile.line_login_channel_id,
                               community_profile.line_login_channel_secret, session[:state])
    redirect_to auth_url, allow_other_host: true
  end

  def line_callback
    # 用於取得存取令牌的授權碼。有效期限10分鐘。此授權碼只能使用一次。
    code = params[:code]

    if params[:state] == session[:state]
      # 取得社區編號
      community_token = params[:community_token]
      community_profile = get_community_by_token(community_token)

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
        @user = User.new(account: uid, oauth_token: id_token)
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

  def get_community_by_token(token)
    community = Community.find_by(token: token)
    if community
      session[:community_id] = community.id
    else
      redirect_to error_notice_path, notice: 'invalid community'
    end
    # Get the community profile
    community_profile = community.profile if community
    return community_profile unless community_profile.nil?

    redirect_to error_notice_path, notice: 'Community profile not found'
  end
end
