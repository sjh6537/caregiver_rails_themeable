class User::HealthReport < ActiveRecord::Base
  belongs_to :user

  # 基本驗證
  validates :bmi, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :height, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :body_fat, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bmr, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :temperature, numericality: { greater_than_or_equal_to: 30, less_than_or_equal_to: 45 }, allow_nil: true
  validates :blood_pressure1, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :blood_pressure2, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :heart_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :blood_sugar, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :blood_oxygen, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :hemoglobin, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hematocrit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :uric_acid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :ketones, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_cholesterol, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
