class AddUserHealthReport < ActiveRecord::Migration[7.1]
  def change
    create_table :user_health_reports do |t|
      t.integer :user_id, null: false, comment: 'User ID'
      t.float :bmi, comment: 'BMI'
      t.float :weight, comment: '體重'
      t.integer :heart_rate, comment: '心跳'
      t.integer :blood_pressure1, comment: '收縮壓'
      t.integer :blood_pressure2, comment: '舒張壓'
      t.integer :blood_sugar, comment: '血糖'
      t.integer :blood_oxygen, comment: '血氧濃度'
      t.integer :body_fat, comment: '體脂'
      t.float :temperature, comment: '體溫'
      t.float :hemoglobin, comment: '血紅素'
      t.float :hematocrit, comment: '血球容積比'
      t.float :uric_acid, comment: '尿酸'
      t.float :total_cholesterol, comment: '總膽固醇'
      t.float :ketones, comment: '酮體'
      t.timestamp :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamp :updated_at, null: false, default: lambda {
        'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
      }, comment: '更新時間'
    end

    add_index 'user_health_reports', ['user_id'], name: 'index_health_report_on_user_id', using: :btree
  end
end
