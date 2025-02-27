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

ActiveRecord::Schema[7.1].define(version: 2025_02_18_071449) do
  create_table "admins", force: :cascade do |t|
    t.string "account"
    t.string "name"
    t.boolean "enable", default: true
    t.boolean "super_admin", default: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account"], name: "index_admins_on_account"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.integer "shop_id"
    t.string "name", limit: 30, default: ""
    t.string "discount", limit: 20, default: ""
    t.text "comment", limit: 1000, default: ""
    t.boolean "is_vaild", default: true
    t.integer "number_stock", default: 0
    t.datetime "period_start"
    t.datetime "period_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.string "full_image_file_name"
    t.string "full_image_content_type"
    t.bigint "full_image_file_size"
    t.datetime "full_image_updated_at"
    t.string "rule", limit: 30, default: ""
    t.integer "redeem"
    t.integer "number_used", default: 0
  end

  create_table "history_logs", force: :cascade do |t|
    t.integer "source"
    t.integer "source_id"
    t.integer "target"
    t.integer "target_id"
    t.integer "action"
    t.string "data", limit: 30
    t.string "description", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_categories", force: :cascade do |t|
    t.boolean "is_show", default: false
    t.string "text", limit: 30, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_messages", force: :cascade do |t|
    t.string "job_id"
    t.integer "message_type", default: 0
    t.text "user_ids"
    t.string "schedule_name"
    t.string "message_text"
    t.datetime "scheduled_time"
    t.datetime "execution_time"
    t.integer "status", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_images", force: :cascade do |t|
    t.integer "shop_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_pictures", force: :cascade do |t|
    t.integer "shop_id"
    t.string "url", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", force: :cascade do |t|
    t.boolean "is_show", default: false
    t.integer "addr_city", default: 0
    t.integer "addr_postal", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "category", default: 0
    t.text "description"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "name", limit: 200, default: ""
    t.string "phone", limit: 200, default: ""
    t.string "address", limit: 200, default: ""
    t.string "price", limit: 200, default: ""
    t.string "service", limit: 200, default: ""
    t.string "opening", limit: 200, default: ""
    t.string "map_id", limit: 20, default: "", null: false
    t.index ["map_id"], name: "index_map_id"
  end

  create_table "user_coupons", force: :cascade do |t|
    t.integer "user_id"
    t.integer "coupon_id"
    t.boolean "is_vaild", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "used_datetime"
    t.boolean "is_used", default: false
    t.boolean "is_expired", default: false
  end

  create_table "user_health_reports", force: :cascade do |t|
    t.integer "user_id"
    t.float "bmi"
    t.integer "heart_rate"
    t.integer "blood_pressure1"
    t.integer "blood_pressure2"
    t.integer "blood_sugar"
    t.integer "blood_oxygen"
    t.integer "body_fat"
    t.float "temperature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "hemoglobin"
    t.string "hematocrit"
    t.string "uric_acid"
    t.string "total_cholesterol"
    t.string "weight"
    t.string "ketones"
  end

  create_table "user_history_coins", force: :cascade do |t|
    t.integer "user_id"
    t.integer "category"
    t.integer "category_id"
    t.integer "number", default: 0
    t.string "description", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "line_uid", default: "", null: false
    t.string "line_token", default: "", null: false
    t.string "line_name"
    t.string "line_image"
    t.string "line_phone"
    t.string "line_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "coins_this_y", default: 0
    t.integer "coins_next_y", default: 0
    t.index ["line_uid"], name: "index_user_profiles_on_line_uid", unique: true
  end

  create_table "user_request_receivers", force: :cascade do |t|
    t.integer "request_id"
    t.integer "receiver_id"
    t.boolean "response", default: false
    t.integer "count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "consider", default: 0
  end

  create_table "user_requests", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "enable", default: true
    t.integer "status", default: 0
    t.integer "helper_id"
    t.integer "category", default: 0
    t.string "title", limit: 30, default: ""
    t.string "location", limit: 30, default: ""
    t.string "contact_info", limit: 30, default: ""
    t.string "descrition", limit: 300, default: "", null: false
    t.datetime "request_date"
    t.integer "request_time"
    t.integer "reward", default: 1
    t.boolean "reward_status", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "location_city", default: 0
    t.integer "location_postal", default: 0
  end

  create_table "user_users_releated_caregivers", force: :cascade do |t|
    t.integer "cared_id"
    t.integer "caregiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_users_releated_friends", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.boolean "block", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "account"
    t.boolean "enable", default: true
    t.string "email", default: ""
    t.text "oauth_token"
    t.datetime "authentication_token_created_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "remember_token"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "phone", default: ""
    t.boolean "sex", default: true
    t.string "address", default: ""
    t.integer "addr_city", default: 0
    t.integer "addr_postal", default: 0
    t.datetime "birthday"
    t.boolean "new_immigrant", default: false
    t.string "id_card"
    t.index ["account"], name: "index_users_on_account", unique: true
    t.index ["id_card"], name: "index_users_on_id_card"
    t.index ["oauth_token"], name: "index_users_on_oauth_token", unique: true
  end

end
