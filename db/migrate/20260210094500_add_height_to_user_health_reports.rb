class AddHeightToUserHealthReports < ActiveRecord::Migration[7.1]
  def change
    add_column :user_health_reports, :height, :float, comment: '身高'
  end
end
