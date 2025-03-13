class HistoryLog < ActiveRecord::Base
  def happen_date
    updated_at.localtime.strftime('%Y-%m-%d %R')
  end
end
