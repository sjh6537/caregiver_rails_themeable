class AddBmrToUserHealthReports < ActiveRecord::Migration[7.1]
  def change
    add_column :user_health_reports, :bmr, :integer, comment: '基礎代謝'
  end
end
