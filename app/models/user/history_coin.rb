class User::HistoryCoin < ActiveRecord::Base

    belongs_to :user

    def happen_date
        self.updated_at.strftime('%Y-%m-%d %R')
    end

    def deliver_name
        if self.category == COINS_GET_SYSTEM
            admin = Admin.find(self.category_id)
            if !admin.nil?
                return admin.account
            end
        end
        nil
    end

end
