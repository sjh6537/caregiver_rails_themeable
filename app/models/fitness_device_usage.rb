class FitnessDeviceUsage < ApplicationRecord
  belongs_to :fitness_device
  belongs_to :user

  # 狀態定義
  enum status: {
    in_use: 0,      # 使用中
    completed: 1    # 已完成
  }

  # 驗證
  validates :start_time, presence: true
  validates :fitness_device_id, presence: true
  validates :user_id, presence: true
  validate :end_time_after_start_time, if: :end_time?

  # 範圍查詢
  scope :recent, -> { order(start_time: :desc) }
  scope :current_month, -> { where(start_time: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_device, ->(device_id) { where(fitness_device_id: device_id) }
  scope :by_date_range, lambda { |start_date, end_date|
    where(start_time: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date
  }

  before_save :calculate_duration

  # 格式化時間範圍
  def time_range
    if start_time && end_time
      "#{start_time.strftime('%m/%d %H:%M')} - #{end_time.strftime('%H:%M')}"
    elsif start_time
      "#{start_time.strftime('%m/%d %H:%M')} - 使用中"
    else
      '時間未知'
    end
  end

  def duration_formatted
    return '使用中' unless duration_minutes

    hours = duration_minutes / 60
    minutes = duration_minutes % 60

    if hours > 0
      "#{hours}小時#{minutes}分鐘"
    else
      "#{minutes}分鐘"
    end
  end

  def end_usage!
    update!(
      end_time: Time.current,
      status: :completed
    )
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    return unless end_time <= start_time

    errors.add(:end_time, '必須晚於開始時間')
  end

  def calculate_duration
    return unless start_time && end_time

    self.duration_minutes = ((end_time - start_time) / 60).round
  end
end
