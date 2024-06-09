class HistoryLog < ActiveRecord::Base

    def happen_date
        self.updated_at.localtime.strftime('%Y-%m-%d %R')
    end

end
