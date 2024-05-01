module LineHelper

    def login_authorize(callback, client_id, client_secret , state)
        ##state = SecureRandom.urlsafe_base64
        # 參考 https://developers.line.biz/en/docs/line-login/integrate-line-login/#making-an-authorization-request
        client = OAuth2::Client.new(client_id, client_secret, :site => APP_CONFIG[:line_authorize_url], :authorize_url => "", :token_method => :post)
        auth_url = client.auth_code.authorize_url(
            :response_type => 'code',
            :redirect_uri => callback,
            :scope => 'profile openid', # 參考https://developers.line.biz/en/docs/line-login/integrate-line-login/#scopes
            :state => state
        )
        auth_url
    end
    
    def login_token(callback, client_id, client_secret, code)
        # 參考 https://developers.line.biz/en/reference/line-login/#issue-access-token
        client = OAuth2::Client.new(client_id, client_secret, :site => APP_CONFIG[:line_api_token_url], :authorize_url => "", :token_url => "", :token_method => :post)
        # headers already define in Client.get_token
        # headers_options: {'Content-Type' => 'application/x-www-form-urlencoded'}
        body_options = {
            grant_type: 'authorization_code',
            code: code,
            redirect_uri: callback,
            client_id: client_id,
            client_secret: client_secret
        }
        client.get_token(body_options)
    end
    
    def login_get_profile(client_id, client_secret, uid_token , access_token)
        # 參考 https://developers.line.biz/ja/docs/line-login/verify-id-token/
        response = access_token.post(APP_CONFIG[:line_api_verify_url], {body: {:id_token => uid_token, :client_id => client_id}})
        response.response.env.response_body
    end
    
end
    