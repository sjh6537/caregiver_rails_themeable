# app/models/cared_facility_event.rb
class CaredFacilityEvent < ApplicationRecord
  belongs_to :cared_facility, optional: true
  belongs_to :cared_user_info, optional: true
  belongs_to :cared_facility_event_type, optional: true

  # 驗證
  validates :cared_facility_id, presence: true

  # 如果你有 enum 或其他邏輯，可以放這裡
end
