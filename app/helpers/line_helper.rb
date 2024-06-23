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

    def message_schedule(time , client_ids, text)
        current_time = DateTime.now.utc

        if(text == nil)
            return
        end

        if(time == nil)
            job_id = NotifySender.perform_async(client_ids, text)
        else
            if time <= current_time
                job_id = NotifySender.perform_async(client_ids, text)
            else
                job_id = NotifySender.perform_at(time, client_ids, text)
            end
        end
    end

    def message_push(client_ids, text)
        if(text == nil)
            return
        end

        message = message_package_text(text)

        if(client_ids == nil)
            LinemsgController.new.client.broadcast(message)
        else
            if client_ids.kind_of?(Array)
                if client_ids.count == 0
                    LinemsgController.new.client.broadcast(message)
                else
                    client_ids.each do | uid |
                        LinemsgController.new.client.push_message(uid, message)
                    end
                end
            else
                LinemsgController.new.client.push_message(client_ids, message)
            end
        end
    end

    def message_package_text(text)
        {
            type: 'text',
            text: text
        }
    end

    def message_package_sticker(package_id, sticker_id)
        {
            type: 'text',
            packageId: package_id,
            stickerId: sticker_id
        }
    end

    def message_package_image(target_image, preview_image)
        {
            type: 'image',
            originalContentUrl: target_image,
            previewImageUrl: preview_image
        }
    end

    def message_package_video(target_video, preview_image, track_id)
        {
            type: 'video',
            originalContentUrl: target_video,
            previewImageUrl: preview_image,
            trackingId: track_id
        }
    end

    def message_package_audio(target_audio, preview_image, millisec)
        {
            type: 'audio',
            originalContentUrl: target_audio,
            duration: millisec
        }
    end

    def message_package_location(title, map_address, latitude, longitude)
        {
            type: 'location',
            title: title,
            address: map_address,
            latitude: latitude,
            longitude: longitude
        }
    end

    def message_package_imagemap()
        {
            #TODO
        }
    end

    def message_package_template()
        {
            #TODO
        }
    end

    def message_package_flex()
        {
            #TODO
        }
    end
end
