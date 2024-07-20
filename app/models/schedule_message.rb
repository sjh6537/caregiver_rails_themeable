class ScheduleMessage < ApplicationRecord
    require 'json'
    validates :scheduled_time, presence: true

    def user_number
        JSON.parse(self.user_ids).count
    end

    def users_text
        users_text = ""
        JSON.parse(self.user_ids).each do |id|
            user = User.find(id)
            if !user.nil?
                if (users_text != "")
                    users_text += ", "
                end
                users_text += user.name
            end
        end
        return users_text
    end

    def status_text
        if self.status == SCHEDULE_MESSAGE_NEW
            if (self.scheduled_time.nil? || self.scheduled_time <= DateTime.now)
                return '<div class="text-danger">錯誤</div>'
            else
                return '<div class="text-success">未發送</div>'
            end
        elsif self.status == SCHEDULE_MESSAGE_SENDED
            return '<div class="text-primary">已發送</div>'
        elsif self.status == SCHEDULE_MESSAGE_FAIL
            return '<div class="text-danger">發送失敗</div>'
        end
    end

    def scheduled_time_text
        if !self.scheduled_time.nil?
            self.scheduled_time.strftime('%Y/%m/%d %I:%M %p')
        else
            ""
        end
    end

    def execution_time_text
        if !self.execution_time.nil?
            self.execution_time.strftime('%Y/%m/%d %I:%M %p')
        else
            ""
        end
    end

    def client_ids
        recipients = []
        JSON.parse(self.user_ids).each do |id|
            user = User.find(id)
            if !user.nil?
                recipients << user.account
            end
        end
        return recipients
    end

end
