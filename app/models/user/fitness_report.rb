class User::FitnessReport < ApplicationRecord
  # 關聯關係
  belongs_to :user
  belongs_to :fitness_device, optional: true

  # 驗證
  # fitness_device 為非必填欄位
  validates :exercise_type, presence: true
  validates :report_date, presence: false
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :intensity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :calories_burned, numericality: { greater_than_or_equal_to: 0 }
  validates :notes, length: { maximum: 200 }

  # 範疇
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_date_range, ->(start_date, end_date) { where(report_date: start_date..end_date) }

  # 計算運動時長（如果未設定）
  before_save :calculate_duration

  private

  def calculate_duration
    return if duration.present? && duration > 0
    return unless start_time && end_time

    self.duration = (end_time - start_time).to_i
  end
end
