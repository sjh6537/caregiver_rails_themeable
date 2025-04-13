class AddRequests < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_requests', force: :cascade do |t|
      t.integer  'user_id', comment: '使用者ID'
      t.boolean  'enable', comment: '是否啟用', default: true
      t.integer  'status', comment: '狀態：0=等待處理，1=已接受，2=已完成', default: 0
      t.integer  'helper_id', comment: '協助者ID', default: nil
      t.integer  'category', comment: '請求類別', default: 0
      t.string   'title', comment: '標題', limit: 30, default: ''
      t.string   'location', comment: '地點', limit: 30, default: ''
      t.integer  'location_city', comment: '城市代碼', default: 0
      t.integer  'location_postal', comment: '郵遞區號', default: 0
      t.string   'contact_info', comment: '聯絡資訊', limit: 30, default: ''
      t.string   'description', comment: '詳細描述', limit: 300, default: '', null: false
      t.datetime 'request_date', comment: '請求日期'
      t.integer  'request_time', comment: '請求時間（小時）'
      t.integer  'reward', comment: '獎勵點數', default: 1
      t.boolean  'reward_status', comment: '獎勵狀態：false=未發放，true=已發放', default: false
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'user_request_receivers', force: :cascade do |t|
      t.integer  'request_id', comment: '請求ID'
      t.integer  'user_id', comment: '接收使用者ID'
      t.integer  'consider', default: 0, comment: '考慮狀態：0=未考慮，1=接受，2=拒絕'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'user_users_releated_caregivers', force: :cascade do |t|
      t.integer  'cared_id', comment: '被照顧者ID'
      t.integer  'caregiver_id', comment: '照顧者ID'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end
  end
end
