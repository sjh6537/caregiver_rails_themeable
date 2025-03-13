class Init < ActiveRecord::Migration[7.1]
  def change

	create_table "admins", force: :cascade do |t|
		t.string   "account"
		t.string   "name"
		t.boolean  "enable",                 default: true
		t.boolean  "super_admin",            default: false
		t.string   "email",                  default: "",    null: false
		t.string   "encrypted_password",     default: "",    null: false
		t.string   "reset_password_token"
		t.datetime "reset_password_sent_at"
		t.datetime "remember_created_at"
		t.integer  "sign_in_count",          default: 0
		t.datetime "current_sign_in_at"
		t.datetime "last_sign_in_at"
		t.string   "current_sign_in_ip"
		t.string   "last_sign_in_ip"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

    add_index "admins", ["account"], name: "index_admins_on_account", using: :btree
    add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
    add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

	create_table "users", force: :cascade do |t|
		t.string   "name"
		t.string   "account"
		t.boolean  "enable",                 default: true
		t.string "email", 					 default: ""

		t.text "oauth_token"
		t.datetime "authentication_token_created_at"

		t.string   "encrypted_password",                default: "",     null: false
		t.string   "reset_password_token"
		t.datetime "reset_password_sent_at"
		t.datetime "remember_created_at"
		t.string   "remember_token"
		t.integer  "sign_in_count",          default: 0
		t.datetime "current_sign_in_at"
		t.datetime "last_sign_in_at"
		t.string   "current_sign_in_ip"
		t.string   "last_sign_in_ip"
		t.datetime "created_at"
		t.datetime "updated_at"
	end

	add_index "users", ["account"], name: "index_users_on_account", unique: true, using: :btree
	add_index "users", ["oauth_token"], name: "index_users_on_oauth_token", unique: true, using: :btree, length: { oauth_token: 255 }  end
end
