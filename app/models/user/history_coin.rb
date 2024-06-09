class User::HistoryCoin < ActiveRecord::Base

    belongs_to :user

    def happen_date
        self.updated_at.strftime('%Y-%m-%d %R')
    end

end
