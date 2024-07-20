class NotifySender
    include Sidekiq::Worker
    include LineHelper
    sidekiq_options retry: false

    def perform(schedule_id)
        schedule = ScheduleMessage.find(schedule_id)
        if !schedule.nil?
            if (message_push(schedule.client_ids, schedule.message_text) == true)
                schedule.update(execution_time: DateTime.now, status: 1)  #SCHEDULE_MESSAGE_SENDED
            end
        end
    end


end
