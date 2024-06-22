class NotifySender
    include Sidekiq::Worker
    include LineHelper
    sidekiq_options retry: false
    
    def perform(recipients, line_message)
        message_push(recipients, line_message)
    end


end
