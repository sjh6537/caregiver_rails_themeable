class LinemsgController < ApplicationController

    def notify
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']

        unless client.validate_signature(body, signature)
            # error 400 do 'Bad Request' end
            head :bad_request
            return
        end

        events = client.parse_events_from(body)
        events.each do |event|
        case event
            when Line::Bot::Event::Message
        case event.type
            when Line::Bot::Event::MessageType::Text
                # Process test
                # UpdateLineUserData(event)
                # PrintAllUserList()
                message = LineUserMessageHandler(event)
                lineID = event['source']['userId']
                # lineID = "2004637485"
                # LineUserCommunicateHandler(client, message)
                # client.reply_message(event['replyToken'], message)
                client.push_message(lineID, message)
                when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
                    # Process image or video
                    response = client.get_message_content(event.message['id'])
                    tf = Tempfile.open("content")
                    tf.write(response.body)
                end
            end
        end
        head :ok
    end

    def push
        if params[:text].present?
            text = params[:text]
            @lineuser = User.find_by_id(params[:id])
            print "#{@lineuser.account}"
            message = LineUserMessagePackage(text, nil)
            client.push_message(@lineuser.account, message)
        end
    end

    def broadcast
        if params[:text].present?
            text = params[:text]
            message = LineUserMessagePackage(text, nil)
            client.broadcast(message)
        end
    end

    def client
        @client ||= Line::Bot::Client.new { |config|
            config.channel_id = APP_CONFIG[:line_message_api_channel_id]
            config.channel_secret = APP_CONFIG[:line_message_api_channel_secret]
            config.channel_token = APP_CONFIG[:line_message_api_channel_token]
        }
    end

    def UpdateLineUserData(event)
        user_id = event['source']['userId']
        User.find_or_create_by(line_id: user_id)
    end

    def PrintAllUserList()
        @line_users = User.all
        @line_users.each do |line_user|
            print "ID: #{line_user.line_id}, Name: #{line_user.name}, Gender: #{line_user.gender}, Birth Date: #{line_user.birth_date} \r\n"
        end
    end

    def LineUserMessageHandler(event)
        case event.message['text']
        when "Hello"
            targetMessage = {
                type: 'template',
                altText: 'This is a template message',
                template: {
                    type: 'buttons',
                    title: 'Do you want my power',
                    text: 'Please select an option',
                    actions: [
                        { type: 'message', label: 'Blue Pill', text: 'Blue Pill selected' },
                        { type: 'message', label: 'Red Pill', text: 'Red Pill selected' }
                    ]
                }
            }
            return targetMessage
        else
          targetMessage = {
            type: 'text',
            text: '來點新鮮的!
請加入好友已獲得更多幫助💚
開啟通知，線上取號叫號推播📱不漏接⭐'
            }
            return targetMessage
        end
    end

    def LineUserMessagePackage(text, picture)
        if picture == nil
            targetMessage = {
                type: 'text',
                text: text
            }
            return targetMessage
        else
            targetMessage = {
                type: 'template',
                altText: 'This is a template message',
                template: {
                    type: 'buttons',
                    title: 'Do you want my power',
                    text: 'Please select an option',
                    actions: [
                        { type: 'message', label: 'Blue Pill', text: 'Blue Pill selected' },
                        { type: 'message', label: 'Red Pill', text: 'Red Pill selected' }
                    ]
                }
            }
            return targetMessage
        end
    end
end
