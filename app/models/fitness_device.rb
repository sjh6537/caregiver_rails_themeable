class FitnessDevice < ApplicationRecord
  # 關聯關係
  belongs_to :community
  belongs_to :fitness_device_type
  has_many :user_fitness_reports, dependent: :restrict_with_error
  belongs_to :user, optional: true

  # 驗證
  validates :name, presence: true, length: { maximum: 50 }
  validates :brand, length: { maximum: 50 }
  validates :model, length: { maximum: 50 }
  validates :serial_number, length: { maximum: 50 }
  validates :mac_address, length: { maximum: 50 }
  validates :ip_address, length: { maximum: 50 }
  validates :location, length: { maximum: 100 }
  validates :status, length: { maximum: 20 }
  validates :img_path, length: { maximum: 100 }
  validates :notes, length: { maximum: 200 }
  validates :sort_order, numericality: { only_integer: true }

  # 範疇
  scope :enabled, -> { where(enabled: true) }
  scope :by_community, ->(community_id) { where(community_id: community_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end
