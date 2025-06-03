# app/models/cared_facility.rb
class CaredFacility < ApplicationRecord
  # 你可以在這裡定義關聯，例如：
  belongs_to :cared_user, class_name: 'User', foreign_key: 'cared_user_info_id', optional: true
  belongs_to :cared_facility_type, optional: true
  has_many :cared_facility_events

  # 驗證
  validates :name, presence: true

  # 更多邏輯可視需求補上
end
