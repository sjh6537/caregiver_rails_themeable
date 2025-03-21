class FitnessDeviceType < ApplicationRecord
  # 關聯關係
  has_many :fitness_devices, dependent: :restrict_with_error

  # 驗證
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :description, length: { maximum: 100 }
  validates :icon, length: { maximum: 50 }
  validates :icon_color, length: { maximum: 20 }
  validates :notes, length: { maximum: 200 }
  validates :sort_order, numericality: { only_integer: true }
end
