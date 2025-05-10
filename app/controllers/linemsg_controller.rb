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
          message = LineUserMessageHandler(event)
          lineID = event['source']['userId']
          # LineUserMessageHandler(client, message)
          # client.reply_message(event['replyToken'], message)
          # client.push_message(lineID, message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          # Process image or video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open('content')
          tf.write(response.body)
        end
      end
    end
    head :ok
  end

  def client(channel_id = nil, channel_secret = nil, channel_token = nil)
    Line::Bot::Client.new do |config|
      config.channel_id = channel_id || APP_CONFIG[:line_message_api_channel_id]
      config.channel_secret = channel_secret || APP_CONFIG[:line_message_api_channel_secret]
      config.channel_token = channel_token || APP_CONFIG[:line_message_api_channel_token]
    end
  end

  def UpdateLineUserData(event)
    user_id = event['source']['userId']
    User.find_or_create_by(account: user_id)
  end

  def LineUserMessageHandler(event)
    case event.message['text']
    when 'Hello'
      {
        type: 'template',
        altText: 'This is a template message',
        template: {
          type: 'buttons',
          title: 'Do you want to register',
          text: 'Please select an option',
          actions: [
            { type: 'message', label: 'Blue Pill', text: 'Blue Pill selected' },
            { type: 'message', label: 'Red Pill', text: 'Red Pill selected' }
          ]
        }
      }
    else
      {
        type: 'text',
        text: '若需要註冊會員📱
請你輸入 💚register💚'
      }
    end
  end
end
