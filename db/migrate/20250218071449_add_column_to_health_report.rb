class AddColumnToHealthReport < ActiveRecord::Migration[7.1]
  def change
    add_column :user_health_reports, :hemoglobin, :string
    add_column :user_health_reports, :hematocrit, :string
    add_column :user_health_reports, :uric_acid, :string
    add_column :user_health_reports, :total_cholesterol, :string
    add_column :user_health_reports, :weight, :string
    add_column :user_health_reports, :ketones, :string
  end
end
