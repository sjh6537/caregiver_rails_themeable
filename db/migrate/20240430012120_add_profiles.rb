class AddProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_profiles', force: :cascade do |t|
      t.integer  'user_id', comment: '使用者 ID'
      t.string   'line_uid', default: '', null: false, comment: 'LINE 使用者唯一識別碼'
      t.text 'line_token', null: false, comment: 'LINE 存取權杖'
      t.string 'line_name', comment: 'LINE 使用者名稱'
      t.text 'line_image', comment: 'LINE 頭像圖片網址'
      t.string   'line_phone', comment: 'LINE 綁定電話號碼'
      t.string   'line_email', comment: 'LINE 綁定電子郵件'
      t.integer  'coins_this_y', default: 0, comment: '本年度點數'
      t.integer  'coins_next_y', default: 0, comment: '下年度點數'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    add_index 'user_profiles', [:line_uid], unique: true, using: :btree
  end
end
