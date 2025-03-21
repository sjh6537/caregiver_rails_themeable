class UpdateUserFitnessInfo < ActiveRecord::Migration[7.1]
  def change
    create_table :fitness_device_types do |t|
      t.string :name, comment: '健身器材類型名稱', limit: 50
      t.string :description, comment: '健身器材類型描述', limit: 100
      t.string :icon, comment: '健身器材類型圖示', limit: 50
      t.string :icon_color, comment: '健身器材類型圖示顏色', limit: 20
      t.boolean :enabled, default: true, comment: '是否啟用'
      t.integer :sort_order, default: 0, comment: '排序'
      t.string :notes, comment: '備註', limit: 200
    end

    create_table :fitness_devices do |t|
      t.integer :community_id, comment: '社群ID'
      t.integer :fitness_device_type_id, comment: '健身器材類型ID'
      t.string :map_id, comment: '地圖ID', limit: 20
      t.string :device_id, comment: '健身器材ID', limit: 20
      t.string :name, comment: '健身器材名稱', limit: 50
      t.string :brand, comment: '健身器材品牌', limit: 50
      t.string :model, comment: '健身器材型號', limit: 50
      t.string :serial_number, comment: '健身器材序號', limit: 50
      t.string :mac_address, comment: '健身器材藍牙地址', limit: 50
      t.string :ip_address, comment: '健身器材IP地址', limit: 50
      t.string :location, comment: '健身器材位置', limit: 100
      t.string :status, comment: '健身器材狀態', limit: 20
      t.string :img_path, comment: '健身器材圖片路徑', limit: 100
      t.string :notes, comment: '健身器材備註', limit: 200
      t.string :latitude, comment: '緯度', limit: 20
      t.string :longitude, comment: '經度', limit: 20
      t.boolean :enabled, default: true, comment: '是否啟用'
      t.integer :sort_order, default: 0, comment: '排序'
      t.string :purchased_from, comment: '購買地點', limit: 50
      t.datetime :purchased_at, comment: '購買時間'
      t.datetime :warranty_expiration_at, comment: '保固到期時間'
      t.datetime :last_used_at, comment: '最後使用時間'
      t.datetime :last_maintenance_at, comment: '最後維護時間'
    end

    add_index 'fitness_device_types', ['name'], name: 'index_fitness_device_type_on_name', unique: true, using: :btree
    add_index 'fitness_devices', ['community_id'], name: 'index_fitness_device_on_community_id', using: :btree

    create_table :user_fitness_reports do |t|
      t.integer :user_id, comment: 'User ID'
      t.integer :fitness_device_id, comment: '健身器材ID'
      t.string :exercise_type, comment: '運動類型（律動機、跑步、深蹲等）', limit: 20
      t.datetime :report_date, comment: '量測日'
      t.datetime :start_time, comment: '運動開始時間'
      t.datetime :end_time, comment: '運動結束時間'
      t.integer :duration, default: 0, comment: '運動時長(秒)'
      t.integer :intensity, default: 0, comment: '運動強度'
      t.float :calories_burned, default: 0, comment: '運動消耗卡路里'
      t.string :notes, comment: '備註', limit: 200
      t.timestamp :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamp :updated_at, null: false, default: lambda {
        'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
      }, comment: '更新時間'
    end

    add_index 'user_fitness_reports', ['user_id'], name: 'index_fitness_report_on_user_id', using: :btree
  end
end
