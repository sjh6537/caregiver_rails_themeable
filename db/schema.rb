# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_21_053143) do
  create_table "admins", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "account", limit: 50, default: "", null: false, comment: "帳號"
    t.string "name", limit: 50, default: "", null: false, comment: "姓名"
    t.string "community_manager", limit: 200, default: "", comment: "社區管理名單，以逗號分隔，可用*代表所有全部社區"
    t.boolean "enable", default: true, null: false, comment: "啟用"
    t.boolean "super_admin", default: false, null: false, comment: "超級管理員"
    t.string "email", limit: 200, default: "", null: false, comment: "電子郵件"
    t.string "title", limit: 50, comment: "職稱"
    t.string "phone", limit: 20, default: "", comment: "電話"
    t.string "encrypted_password", default: "", null: false, comment: "密碼"
    t.string "reset_password_token", limit: 200, comment: "重設密碼token"
    t.datetime "reset_password_sent_at", comment: "重設密碼發送時間"
    t.datetime "remember_created_at", comment: "記住我時間"
    t.integer "sign_in_count", default: 0, comment: "登入次數"
    t.datetime "current_sign_in_at", comment: "當前登入時間"
    t.datetime "last_sign_in_at", comment: "上次登入時間"
    t.string "current_sign_in_ip", limit: 50, comment: "當前登入IP"
    t.string "last_sign_in_ip", limit: 50, comment: "上次登入IP"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
    t.index ["account"], name: "index_admins_on_account"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "communities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "sn", limit: 200, null: false, comment: "編號"
    t.string "name", limit: 50, null: false, comment: "名稱"
    t.string "name_eng", limit: 100, comment: "英文名稱"
    t.string "description", limit: 50, comment: "描述"
    t.string "agreement_path", limit: 200, comment: "使用者協議路徑"
    t.boolean "enable", default: true, null: false, comment: "是否啟用"
    t.integer "sort", default: 0, null: false, comment: "排序"
    t.string "logo", limit: 200, comment: "logo"
    t.string "status", limit: 50, comment: "狀態"
    t.string "address", limit: 200, comment: "地址"
    t.string "phone", limit: 20, comment: "電話"
    t.string "email", limit: 50, comment: "信箱"
    t.string "contact_name", limit: 50, comment: "聯絡人姓名"
    t.string "contact_phone", limit: 20, comment: "聯絡人電話"
    t.string "contact_email", comment: "聯絡人信箱"
    t.string "contact_title", limit: 50, comment: "聯絡人職稱"
    t.string "note", limit: 50, comment: "備註"
    t.string "comment", limit: 50, comment: "社區備註"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sn"], name: "index_communities_on_sn", unique: true
  end

  create_table "community_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "community_id", null: false, comment: "社區ID"
    t.string "line_at_url", limit: 500, comment: "lineAtUrl"
    t.string "line_login_channel_id", limit: 50, comment: "LineLoginId"
    t.string "line_login_channel_secret", limit: 500, comment: "LineLoginSecret"
    t.string "line_login_channel_callback_url", limit: 500, comment: "LineLoginCallback"
    t.string "line_message_api_channel_id", limit: 50, comment: "LineMessageApiId"
    t.string "line_message_api_channel_secret", limit: 200, comment: "LineMessageApiSecret"
    t.string "line_message_api_channel_token", limit: 500, comment: "LineMessageApiToken"
    t.string "line_message_api_channel_callback_url", limit: 200, comment: "LineMessageApiCallback"
    t.string "line_liff_id", limit: 50, comment: "LineLiffId"
    t.string "line_liff_url", limit: 200, comment: "LineLiffUrl"
    t.string "google_map_key", limit: 200, comment: "GoogleMapKey"
    t.string "note", limit: 50, comment: "備註"
    t.string "comment", limit: 50, comment: "備註"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupons", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "shop_id", comment: "商店ID"
    t.string "name", limit: 30, default: "", comment: "優惠券名稱"
    t.string "discount", limit: 20, default: "", comment: "折扣內容"
    t.text "comment", comment: "優惠說明"
    t.string "rule", limit: 30, default: "", comment: "使用規則"
    t.integer "redeem", comment: "兌換點數"
    t.boolean "is_vaild", default: true, comment: "是否有效"
    t.integer "number_stock", default: 0, comment: "剩餘庫存"
    t.integer "number_used", default: 0, comment: "已使用數量"
    t.datetime "period_start", comment: "優惠開始時間"
    t.datetime "period_end", comment: "優惠結束時間"
    t.string "image_file_name", comment: "圖片檔案名稱"
    t.string "image_content_type", comment: "圖片內容類型"
    t.bigint "image_file_size", comment: "圖片檔案大小"
    t.datetime "image_updated_at", comment: "圖片更新時間"
    t.string "full_image_file_name", comment: "完整圖片檔案名稱"
    t.string "full_image_content_type", comment: "完整圖片內容類型"
    t.bigint "full_image_file_size", comment: "完整圖片檔案大小"
    t.datetime "full_image_updated_at", comment: "完整圖片更新時間"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "fitness_device_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50, comment: "健身器材類型名稱"
    t.string "description", limit: 100, comment: "健身器材類型描述"
    t.string "icon", limit: 50, comment: "健身器材類型圖示"
    t.string "icon_color", limit: 20, comment: "健身器材類型圖示顏色"
    t.boolean "enabled", default: true, comment: "是否啟用"
    t.integer "sort_order", default: 0, comment: "排序"
    t.string "notes", limit: 200, comment: "備註"
    t.index ["name"], name: "index_fitness_device_type_on_name", unique: true
  end

  create_table "fitness_devices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "community_id", comment: "社群ID"
    t.integer "fitness_device_type_id", comment: "健身器材類型ID"
    t.string "map_id", limit: 20, comment: "地圖ID"
    t.string "device_id", limit: 20, comment: "健身器材ID"
    t.string "name", limit: 50, comment: "健身器材名稱"
    t.string "brand", limit: 50, comment: "健身器材品牌"
    t.string "model", limit: 50, comment: "健身器材型號"
    t.string "serial_number", limit: 50, comment: "健身器材序號"
    t.string "mac_address", limit: 50, comment: "健身器材藍牙地址"
    t.string "ip_address", limit: 50, comment: "健身器材IP地址"
    t.string "location", limit: 100, comment: "健身器材位置"
    t.string "status", limit: 20, comment: "健身器材狀態"
    t.string "img_path", limit: 100, comment: "健身器材圖片路徑"
    t.string "notes", limit: 200, comment: "健身器材備註"
    t.string "latitude", limit: 20, comment: "緯度"
    t.string "longitude", limit: 20, comment: "經度"
    t.boolean "enabled", default: true, comment: "是否啟用"
    t.integer "sort_order", default: 0, comment: "排序"
    t.string "purchased_from", limit: 50, comment: "購買地點"
    t.datetime "purchased_at", comment: "購買時間"
    t.datetime "warranty_expiration_at", comment: "保固到期時間"
    t.datetime "last_used_at", comment: "最後使用時間"
    t.datetime "last_maintenance_at", comment: "最後維護時間"
    t.index ["community_id"], name: "index_fitness_device_on_community_id"
  end

  create_table "history_logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "source", comment: "來源類型"
    t.integer "source_id", comment: "來源 ID"
    t.integer "target", comment: "目標類型"
    t.integer "target_id", comment: "目標 ID"
    t.integer "action", comment: "動作類型"
    t.string "data", limit: 30, comment: "額外資料"
    t.string "description", limit: 50, comment: "描述文字"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "request_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "is_show", default: false, comment: "是否顯示"
    t.string "text", limit: 30, default: "", null: false, comment: "類別名稱"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "schedule_messages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "job_id", comment: "工作ID"
    t.integer "message_type", default: 0, comment: "訊息類型"
    t.text "user_ids", comment: "使用者ID列表"
    t.string "schedule_name", comment: "排程名稱"
    t.string "message_text", comment: "訊息內容"
    t.datetime "scheduled_time", comment: "預定時間"
    t.datetime "execution_time", comment: "執行時間"
    t.integer "status", default: 0, comment: "狀態"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "shop_images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "shop_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_pictures", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "shop_id"
    t.string "url", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 200, default: "", comment: "商店名稱"
    t.boolean "is_show", default: false, comment: "是否顯示"
    t.string "phone", limit: 200, default: "", comment: "聯絡電話"
    t.string "address", limit: 200, default: "", comment: "商店地址"
    t.integer "addr_city", default: 0, comment: "城市代碼"
    t.integer "addr_postal", default: 0, comment: "郵遞區號"
    t.string "price", limit: 200, default: "", comment: "價格"
    t.integer "category", default: 0, comment: "類別"
    t.string "service", limit: 200, default: "", comment: "服務"
    t.text "description", comment: "描述"
    t.decimal "latitude", precision: 10, comment: "緯度"
    t.decimal "longitude", precision: 10, comment: "經度"
    t.string "opening", limit: 200, default: "", comment: "營業時間"
    t.string "map_id", limit: 20, default: "", null: false, comment: "地圖ID"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
    t.index ["map_id"], name: "index_map_id"
  end

  create_table "user_coupons", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "使用者ID"
    t.integer "coupon_id", comment: "優惠券ID"
    t.boolean "is_vaild", default: true, comment: "是否有效"
    t.boolean "is_used", default: false, comment: "是否已使用"
    t.boolean "is_expired", default: false, comment: "是否已過期"
    t.datetime "used_datetime", comment: "使用時間"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "user_fitness_reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "User ID"
    t.integer "fitness_device_id", comment: "健身器材ID"
    t.string "exercise_type", limit: 20, comment: "運動類型（律動機、跑步、深蹲等）"
    t.datetime "report_date", comment: "量測日"
    t.datetime "start_time", comment: "運動開始時間"
    t.datetime "end_time", comment: "運動結束時間"
    t.integer "duration", default: 0, comment: "運動時長(秒)"
    t.integer "intensity", default: 0, comment: "運動強度"
    t.float "calories_burned", default: 0.0, comment: "運動消耗卡路里"
    t.string "notes", limit: 200, comment: "備註"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }, null: false, comment: "更新時間"
    t.index ["user_id"], name: "index_fitness_report_on_user_id"
  end

  create_table "user_health_reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "User ID"
    t.datetime "measure_time", null: false, comment: "測量時間"
    t.float "bmi", comment: "BMI"
    t.float "weight", comment: "體重"
    t.integer "heart_rate", comment: "心跳"
    t.integer "blood_pressure1", comment: "收縮壓"
    t.integer "blood_pressure2", comment: "舒張壓"
    t.integer "blood_sugar", comment: "血糖"
    t.integer "blood_oxygen", comment: "血氧濃度"
    t.integer "body_fat", comment: "體脂"
    t.float "temperature", comment: "體溫"
    t.float "hemoglobin", comment: "血紅素"
    t.float "hematocrit", comment: "血球容積比"
    t.float "uric_acid", comment: "尿酸"
    t.float "total_cholesterol", comment: "總膽固醇"
    t.float "ketones", comment: "酮體"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }, null: false, comment: "更新時間"
    t.index ["user_id"], name: "index_health_report_on_user_id"
  end

  create_table "user_history_coins", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "使用者 ID"
    t.integer "category", comment: "類別"
    t.integer "category_id", comment: "類別 ID"
    t.integer "number", default: 0, comment: "數量"
    t.string "description", default: "", comment: "描述"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "使用者 ID"
    t.string "line_uid", default: "", null: false, comment: "LINE 使用者唯一識別碼"
    t.text "line_token", null: false, comment: "LINE 存取權杖"
    t.string "line_name", comment: "LINE 使用者名稱"
    t.text "line_image", comment: "LINE 頭像圖片網址"
    t.string "line_phone", comment: "LINE 綁定電話號碼"
    t.string "line_email", comment: "LINE 綁定電子郵件"
    t.integer "coins_this_y", default: 0, comment: "本年度點數"
    t.integer "coins_next_y", default: 0, comment: "下年度點數"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
    t.index ["line_uid"], name: "index_user_profiles_on_line_uid", unique: true
  end

  create_table "user_request_receivers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "request_id", comment: "請求ID"
    t.integer "receiver_id", comment: "接收者ID"
    t.boolean "response", default: false, comment: "是否回應"
    t.integer "count", default: 0, comment: "計數"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "user_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "使用者ID"
    t.boolean "enable", default: true, comment: "是否啟用"
    t.integer "status", default: 0, comment: "狀態：0=等待處理，1=已接受，2=已完成"
    t.integer "helper_id", comment: "協助者ID"
    t.integer "category", default: 0, comment: "請求類別"
    t.string "title", limit: 30, default: "", comment: "標題"
    t.string "location", limit: 30, default: "", comment: "地點"
    t.integer "location_city", default: 0, comment: "城市代碼"
    t.integer "location_postal", default: 0, comment: "郵遞區號"
    t.string "contact_info", limit: 30, default: "", comment: "聯絡資訊"
    t.string "description", limit: 300, default: "", null: false, comment: "詳細描述"
    t.datetime "request_date", comment: "請求日期"
    t.integer "request_time", comment: "請求時間（小時）"
    t.integer "reward", default: 1, comment: "獎勵點數"
    t.boolean "reward_status", default: false, comment: "獎勵狀態：false=未發放，true=已發放"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "user_users_releated_caregivers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "cared_id", comment: "被照顧者ID"
    t.integer "caregiver_id", comment: "照顧者ID"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "user_users_releated_friends", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id", comment: "使用者ID"
    t.integer "friend_id", comment: "朋友ID"
    t.boolean "block", default: false, comment: "是否封鎖"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "community_id", null: false, comment: "社區ID"
    t.integer "cared_user_info_id", comment: "被照護者ID"
    t.integer "caregiver_user_info_id", comment: "照護者ID"
    t.string "name", limit: 50, default: "", null: false, comment: "姓名"
    t.string "account", limit: 50, default: "", null: false, comment: "帳號"
    t.boolean "enable", default: true, null: false, comment: "啟用"
    t.string "email", limit: 200, default: "", comment: "電子郵件"
    t.string "title", limit: 50, comment: "職稱"
    t.string "phone", limit: 20, default: "", comment: "電話"
    t.string "mobile", limit: 20, default: "", comment: "手機"
    t.string "gender", limit: 1, default: "M", comment: "性別"
    t.string "birthday", limit: 10, default: "", comment: "生日"
    t.string "address", limit: 200, default: "", comment: "地址"
    t.integer "addr_city", default: 0, comment: "城市"
    t.integer "addr_postal", default: 0, comment: "郵遞區號"
    t.string "id_card", limit: 20, comment: "身分證"
    t.string "nhi_id", limit: 20, comment: "健保卡"
    t.boolean "is_accepted", default: false, comment: "是否同意使用者協議"
    t.boolean "new_immigrant", default: false, comment: "新住民"
    t.string "note", limit: 50, comment: "備註"
    t.string "comment", limit: 50, comment: "備註"
    t.text "oauth_token", comment: "OAuth Token"
    t.datetime "authentication_token_created_at", comment: "Token建立時間"
    t.string "encrypted_password", limit: 200, default: "", null: false, comment: "密碼"
    t.string "reset_password_token", limit: 200, comment: "重設密碼token"
    t.datetime "reset_password_sent_at", comment: "重設密碼發送時間"
    t.datetime "remember_created_at", comment: "記住我時間"
    t.string "remember_token", limit: 200, comment: "記住我token"
    t.integer "sign_in_count", default: 0, comment: "登入次數"
    t.datetime "current_sign_in_at", comment: "當前登入時間"
    t.datetime "last_sign_in_at", comment: "上次登入時間"
    t.string "current_sign_in_ip", limit: 50, comment: "當前登入IP"
    t.string "last_sign_in_ip", limit: 50, comment: "上次登入IP"
    t.datetime "created_at", comment: "建立時間"
    t.datetime "updated_at", comment: "更新時間"
    t.index ["account"], name: "index_users_on_account", unique: true
    t.index ["oauth_token"], name: "index_users_on_oauth_token", unique: true, length: 255
  end

end
