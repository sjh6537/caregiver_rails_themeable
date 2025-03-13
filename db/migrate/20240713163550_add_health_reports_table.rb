class AddHealthReportsTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_health_reports', force: :cascade do |t|
      t.integer  'user_id'
      t.float    'bmi',                   default: nil
      t.integer  'heart_rate',            default: nil
      t.integer  'blood_pressure1',       default: nil
      t.integer  'blood_pressure2',       default: nil
      t.integer  'blood_sugar',           default: nil
      t.integer  'blood_oxygen',          default: nil
      t.integer  'body_fat',              default: nil
      t.float    'temperature',           default: nil
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
