class User::Schedule < ApplicationRecord
    self.table_name = 'schedule_events'
    belongs_to :user, foreign_key: 'schedule_id'
    validates :recipient, presence: true
    validates :scheduled_time, presence: true

    def recipients_array
        self.recipients ? self.recipients.split(',') : []
    end

    def recipients_array=(array)
        self.recipients = array.join(',')
    end
end
