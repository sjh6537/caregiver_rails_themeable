class ScheduleMessage < ApplicationRecord
  require 'json'
  validates :scheduled_time, presence: true

  def user_number
    JSON.parse(user_ids).count
  end

  def users_text
    users_text = ''
    JSON.parse(user_ids).each do |id|
      user = User.find(id)
      next if user.nil?

      users_text += ', ' if users_text != ''
      users_text += user.name
    end
    users_text
  end

  def status_text
    case status
    when SCHEDULE_MESSAGE_NEW
      return '<div class="text-danger">錯誤</div>' if scheduled_time.nil? || scheduled_time <= DateTime.now

      '<div class="text-success">未發送</div>'

    when SCHEDULE_MESSAGE_SENDED
      '<div class="text-primary">已發送</div>'
    when SCHEDULE_MESSAGE_FAIL
      '<div class="text-danger">發送失敗</div>'
    end
  end

  def scheduled_time_text
    if scheduled_time.nil?
      ''
    else
      scheduled_time.strftime('%Y/%m/%d %I:%M %p')
    end
  end

  def execution_time_text
    if execution_time.nil?
      ''
    else
      execution_time.strftime('%Y/%m/%d %I:%M %p')
    end
  end

  def client_ids
    recipients = []
    JSON.parse(user_ids).each do |id|
      user = User.find(id)
      recipients << user.account unless user.nil?
    end
    recipients
  end
end
