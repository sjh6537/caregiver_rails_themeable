class RequestNotify
    include Sidekiq::Worker
    include LineHelper
    sidekiq_options retry: false

    def perform(request_id)
        request = User::Request.find_by_id(request_id)
        if !request.nil?
        if !request.owner.nil?
            if !request.helper.nil?
                message_push(request.owner.account , "Hi , 你的派工「#{request.title}」一小時後開始 , #{request.helper.name}已接受")
                message_push(request.helper.account , "Hi , 你接受#{request.owner.name}的派工「#{request.title}」一小時後開始")
            else
                message_push(request.owner.account , "Hi , 你的派工「#{request.title}」一小時後開始 , 目前尚無人接受")
            end
        end
        end
    end

end
