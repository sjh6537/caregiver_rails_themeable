class AddHealthReportsTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_health_reports', force: :cascade do |t|
      t.integer  'user_id'
      t.float    'bmi', default: nil, comment: 'BMI'
      t.float    'weight', default: nil, comment: '體重'
      t.integer  'heart_rate',            default: nil, comment: '心跳'
      t.integer  'blood_pressure1',       default: nil, comment: '收縮壓'
      t.integer  'blood_pressure2',       default: nil, comment: '舒張壓'
      t.integer  'blood_sugar',           default: nil, comment: '血糖'
      t.integer  'blood_oxygen',          default: nil, comment: '血氧濃度'
      t.integer  'body_fat',              default: nil, comment: '體脂'
      t.float    'temperature',           default: nil, comment: '體溫'
      t.float    'hemoglobin',            default: nil, comment: '血紅素'
      t.float    'hematocrit',            default: nil, comment: '血球容積比'
      t.float    'uric_acid',             default: nil, comment: '尿酸'
      t.float    'total_cholesterol',     default: nil, comment: '總膽固醇'
      t.float    'ketones',               default: nil, comment: '酮體'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
