class AddUserFitnessReports < ActiveRecord::Migration[7.1]
  def change
    create_table :user_fitness_reports do |t|
      t.integer :user_id, comment: 'User ID'
      t.integer :fitness_device_id, comment: '健身器材ID'
      t.string :exercise_type, comment: '運動類型（律動機、跑步、深蹲等）'
      t.datetime :report_date, comment: '量測日'
      t.datetime :start_time, comment: '運動開始時間'
      t.datetime :end_time, comment: '運動結束時間'
      t.integer :duration, default: 0, comment: '運動時長(秒)'
      t.integer :intensity, default: 0, comment: '運動強度'
      t.float :calories_burned, default: 0, comment: '運動消耗卡路里'
      t.string :notes, comment: '備註', limit: 200
      t.timestamps
    end

    add_index 'user_fitness_reports', ['user_id'], name: 'index_fitness_report_on_user_id', using: :btree
  end
end
