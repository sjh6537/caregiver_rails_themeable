# -*- encoding : utf-8 -*-
class User::SessionsController < Devise::SessionsController
    skip_before_action :verify_authenticity_token
    include LineHelper
    #include Devise::Controllers::Rememberable

    def line_authorize
        session[:state] = form_authenticity_token
        auth_url = login_authorize(APP_CONFIG[:line_login_callback_url], APP_CONFIG[:line_login_channel_id], APP_CONFIG[:line_login_Channel_secret] , session[:state])
        redirect_to auth_url, allow_other_host: true
    end

    def line_callback
        code = params[:code]
        if params[:state] == session[:state]
            access_token = login_token(APP_CONFIG[:line_login_callback_url], APP_CONFIG[:line_login_channel_id], APP_CONFIG[:line_login_Channel_secret], code)
            id_token = access_token.params[:id_token]

            response_body = login_get_profile(APP_CONFIG[:line_login_channel_id], APP_CONFIG[:line_login_Channel_secret], id_token , access_token)
            uid = JSON.parse(response_body)['sub']
            name = JSON.parse(response_body)['name']
            image = JSON.parse(response_body)['picture']
            email = JSON.parse(response_body)['email']

            @user = User.find_by_account(uid)
            if @user
                #remember_me(@user)
                @user.update(name: name, oauth_token: id_token)
                @user.profile.update(line_name: name,line_token: id_token, line_image: image, line_email: email)
            else
                @user = User.new(account: uid, name: name, oauth_token: id_token)
                if @user.save
                    @user.create_profile(line_uid: uid,line_name: name,line_token: id_token, line_image: image, line_email: email)

                end
                #redirect_to new_user_registration_url
            end
            sign_in(@user)

            redirect_to edit_user_path
        else
            redirect_to error_notice_path, notice: 'invalid varification'
        end
    end

end
