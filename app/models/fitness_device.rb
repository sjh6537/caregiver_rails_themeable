class FitnessDevice < ApplicationRecord
  # 關聯關係
  belongs_to :community, optional: true
  belongs_to :fitness_device_type
  has_many :fitness_device_usages, dependent: :destroy
  belongs_to :user, optional: true

  # 驗證
  validates :device_id, presence: true, uniqueness: true
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
  scope :available, -> { where(user: nil) }
  scope :in_use, -> { where.not(user: nil) }
  scope :ordered, -> { order(:sort_order, :name) }

  # 檢查是否有人正在使用
  def in_use?
    user_id.present?
  end

  def available?
    user_id.blank?
  end

  # 取得目前使用者
  def current_user
    user if in_use?
  end

  # 取得最後使用記錄
  def last_usage
    fitness_device_usages.order(created_at: :desc).first
  end

  # 取得目前使用記錄（狀態為使用中）
  def current_usage
    fitness_device_usages.in_use.first
  end

  # 顯示名稱
  def display_name
    "#{name} (#{device_id})"
  end

  # 綁定使用者
  def bind_user!(new_user)
    ActiveRecord::Base.transaction do
      # 更新設備的使用者
      update!(user: new_user)

      # 建立新的使用記錄
      fitness_device_usages.create!(
        user: new_user,
        start_time: Time.current,
        status: :in_use
      )
    end
  end

  # 解除使用者綁定
  def unbind_user!
    ActiveRecord::Base.transaction do
      # 結束目前的使用記錄
      current_usage_record = current_usage
      if current_usage_record
        current_usage_record.update!(
          end_time: Time.current,
          status: :completed
        )

        # 計算使用時長
        if current_usage_record.start_time && current_usage_record.end_time
          duration = ((current_usage_record.end_time - current_usage_record.start_time) / 60).round
          current_usage_record.update!(duration_minutes: duration)
        end
      end

      # 清除設備的使用者
      update!(user: nil)
    end
  end
end
