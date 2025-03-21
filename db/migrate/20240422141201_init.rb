class Init < ActiveRecord::Migration[7.1]
  def change
    create_table 'admins', force: :cascade do |t|
      t.string   'account',                default: '',    null: false, limit: 50, comment: '帳號'
      t.string   'name',                   default: '',    null: false, limit: 50, comment: '姓名'
      t.string   'community_manager',      default: '',    limit: 200, comment: '社區管理名單，以逗號分隔，可用*代表所有全部社區'
      t.boolean  'enable',                 default: true, null: false, comment: '啟用'
      t.boolean  'super_admin',            default: false, null: false, comment: '超級管理員'
      t.string   'email',                  default: '',    null: false, limit: 200, comment: '電子郵件'
      t.string   'title',                  limit: 50, comment: '職稱'
      t.string   'phone',                  default: '',    limit: 20, comment: '電話'
      t.string   'encrypted_password',     default: '',    null: false, comment: '密碼'
      t.string   'reset_password_token', comment: '重設密碼token', limit: 200
      t.datetime 'reset_password_sent_at', comment: '重設密碼發送時間'
      t.datetime 'remember_created_at',    comment: '記住我時間'
      t.integer  'sign_in_count', default: 0, comment: '登入次數'
      t.datetime 'current_sign_in_at', comment: '當前登入時間'
      t.datetime 'last_sign_in_at', comment: '上次登入時間'
      t.string   'current_sign_in_ip', comment: '當前登入IP', limit: 50
      t.string   'last_sign_in_ip', comment: '上次登入IP', limit: 50
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    add_index 'admins', ['account'], name: 'index_admins_on_account', using: :btree
    add_index 'admins', ['email'], name: 'index_admins_on_email', unique: true, using: :btree
    add_index 'admins', ['reset_password_token'], name: 'index_admins_on_reset_password_token', unique: true,
                                                  using: :btree

    create_table 'users', force: :cascade do |t|
      t.integer 'community_id', null: false, comment: '社區ID'
      t.integer 'cared_user_info_id', comment: '被照護者ID'
      t.integer  'caregiver_user_info_id', comment: '照護者ID'
      t.string   'name',                      default: '',    null: false, limit: 50, comment: '姓名'
      t.string   'account',                   default: '',    null: false, limit: 50, comment: '帳號'
      t.boolean  'enable',                    default: true,  null: false, comment: '啟用'
      t.string   'email',                     default: '',    limit: 200, comment: '電子郵件'
      t.string   'title',                     limit: 50, comment: '職稱'
      t.string   'phone',                     default: '',    limit: 20, comment: '電話'
      t.string   'mobile',                    default: '',    limit: 20, comment: '手機'
      t.string   'gender',                    default: 'M',   limit: 1, comment: '性別'
      t.string   'birthday',                  default: '',    limit: 10, comment: '生日'
      t.string   'address',                   default: '',    limit: 200, comment: '地址'
      t.integer  'addr_city',                 default: 0,     comment: '城市'
      t.integer  'addr_postal',               default: 0,     comment: '郵遞區號'
      t.string   'id_card',                   limit: 20, comment: '身分證'
      t.string   'nhi_id',                    limit: 20, comment: '健保卡'
      t.boolean 'new_immigrant', default: 0 , comment: '新住民'
      t.string   'note',                      limit: 50, comment: '備註'
      t.string   'comment',                   limit: 50, comment: '備註'
      t.text     'oauth_token',               comment: 'OAuth Token'
      t.datetime 'authentication_token_created_at', comment: 'Token建立時間'
      t.string   'encrypted_password',        default: '', null: false, limit: 200, comment: '密碼'
      t.string   'reset_password_token',      limit: 200, comment: '重設密碼token'
      t.datetime 'reset_password_sent_at',    comment: '重設密碼發送時間'
      t.datetime 'remember_created_at',       comment: '記住我時間'
      t.string   'remember_token',            limit: 200, comment: '記住我token'
      t.integer  'sign_in_count',             default: 0, comment: '登入次數'
      t.datetime 'current_sign_in_at',        comment: '當前登入時間'
      t.datetime 'last_sign_in_at',           comment: '上次登入時間'
      t.string   'current_sign_in_ip',        limit: 50, comment: '當前登入IP'
      t.string   'last_sign_in_ip',           limit: 50, comment: '上次登入IP'
      t.datetime 'created_at',                comment: '建立時間'
      t.datetime 'updated_at',                comment: '更新時間'
    end

    add_index 'users', ['account'], name: 'index_users_on_account', unique: true, using: :btree
    add_index 'users', ['oauth_token'], name: 'index_users_on_oauth_token', unique: true, using: :btree,
                                        length: { oauth_token: 255 }

    create_table :communities , force: :cascade do |t|
      t.string :sn, null: false, comment: '編號', limit: 200
      t.string :name, null: false, comment: '名稱', limit: 50
      t.string :name_eng, comment: '英文名稱', limit: 100
      t.string :description, comment: '描述', limit: 50
      t.string :agreement_path, comment: '使用者協議路徑', limit: 200
      t.boolean :enable, null: false, default: true, comment: '是否啟用'
      t.integer :sort, null: false, default: 0, comment: '排序'
      t.string :logo, comment: 'logo', limit: 200
      t.string :status, comment: '狀態', limit: 50
      t.string :address, comment: '地址', limit: 200
      t.string :phone, comment: '電話', limit: 20
      t.string :email, comment: '信箱', limit: 50
      t.string :contact_name, comment: '聯絡人姓名', limit: 50
      t.string :contact_phone, comment: '聯絡人電話', limit: 20
      t.string :contact_email, comment: '聯絡人信箱', limit: 255
      t.string :contact_title, comment: '聯絡人職稱', limit: 50
      t.string :note , comment: '備註', limit: 50
      t.string :comment, comment: '社區備註', limit: 50
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index 'communities', ['sn'], name: 'index_communities_on_sn', unique: true, using: :btree

    create_table :community_profiles, force: :cascade do |t|
      t.integer :community_id, null: false, comment: '社區ID'
      t.string :line_at_url, comment: 'lineAtUrl', limit: 500
      t.string :line_login_channel_id, comment: 'LineLoginId', limit: 50
      t.string :line_login_channel_secret, comment: 'LineLoginSecret', limit: 500
      t.string :line_login_channel_callback_url, comment: 'LineLoginCallback',
                                                 limit: 500
      t.string :line_message_api_channel_id, comment: 'LineMessageApiId', limit: 50
      t.string :line_message_api_channel_secret, comment: 'LineMessageApiSecret',
                                                 limit: 200
      t.string :line_message_api_channel_token, comment: 'LineMessageApiToken',
                                                limit: 500
      t.string :line_message_api_channel_callback_url,
               comment: 'LineMessageApiCallback', limit: 200
      t.string :line_liff_id, comment: 'LineLiffId', limit: 50
      t.string :line_liff_url, comment: 'LineLiffUrl', limit: 200
      t.string :google_map_key, comment: 'GoogleMapKey', limit: 200
      t.string :note, comment: '備註', limit: 50
      t.string :comment, comment: '備註', limit: 50
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
