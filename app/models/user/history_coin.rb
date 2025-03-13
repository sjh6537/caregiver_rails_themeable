module User
  class HistoryCoin < ActiveRecord::Base
    belongs_to :user

    def happen_date
      updated_at.strftime('%Y-%m-%d %R')
    end

    def deliver_name
      if category == COINS_GET_SYSTEM
        admin = Admin.find(category_id)
        return admin.account unless admin.nil?
      end
      nil
    end
  end
end
