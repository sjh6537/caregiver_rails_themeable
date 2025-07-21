class UserHealthOverview < ApplicationRecord
  self.table_name = 'user_health_overview'
  self.primary_key = nil  # 如果 view 中沒有主鍵欄位
end
