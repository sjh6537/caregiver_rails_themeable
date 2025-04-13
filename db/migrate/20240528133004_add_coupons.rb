class AddCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table 'shops', force: :cascade do |t|
      t.string   'name',                       default: '', limit: 200, comment: '商店名稱'
      t.boolean  'is_show',                    default: false, comment: '是否顯示'
      t.string   'phone',                      default: '', limit: 200, comment: '聯絡電話'
      t.string   'address',                    default: '', limit: 200, comment: '商店地址'
      t.integer  'addr_city',                  default: 0, comment: '城市代碼'
      t.integer  'addr_postal',                default: 0, comment: '郵遞區號'
      t.string   'price',                      default: '', limit: 200, comment: '價格'
      t.integer  'category',                   default: 0, comment: '類別'
      t.string   'service',                    default: '', limit: 200, comment: '服務'
      t.text     'description',                comment: '描述'
      t.decimal  'latitude',                   comment: '緯度'
      t.decimal  'longitude',                  comment: '經度'
      t.string   'opening',                    default: '', limit: 200, comment: '營業時間'
      t.string   'map_id',                     default: '', limit: 20, null: false, comment: '地圖ID'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    add_index 'shops', ['map_id'], name: 'index_map_id', using: :btree

    create_table 'shop_pictures', force: :cascade do |t|
      t.integer  'shop_id'
      t.string   'url', default: ''
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    create_table 'shop_images', force: :cascade do |t|
      t.integer  'shop_id'
      t.string   'image_file_name'
      t.string   'image_content_type'
      t.bigint   'image_file_size'
      t.datetime 'image_updated_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    create_table 'coupons', force: :cascade do |t|
      t.integer  'shop_id', comment: '商店ID'
      t.string   'name',                       default: '', limit: 30, comment: '優惠券名稱'
      t.string   'discount',                   default: '', limit: 20, comment: '折扣內容'
      t.text     'comment',                    limit: 1000, comment: '優惠說明'
      t.string   'rule',                       default: '', limit: 30, comment: '使用規則'
      t.integer  'redeem',                     default: nil, comment: '兌換點數'
      t.boolean  'is_vaild',                   default: true, comment: '是否有效'
      t.integer  'number_stock',               default: 0, comment: '剩餘庫存'
      t.integer  'number_used',                default: 0, comment: '已使用數量'
      t.datetime 'period_start', comment: '優惠開始時間'
      t.datetime 'period_end', comment: '優惠結束時間'
      t.string   'image_file_name', comment: '圖片檔案名稱'
      t.string   'image_content_type', comment: '圖片內容類型'
      t.bigint   'image_file_size', comment: '圖片檔案大小'
      t.datetime 'image_updated_at', comment: '圖片更新時間'
      t.string   'full_image_file_name', comment: '完整圖片檔案名稱'
      t.string   'full_image_content_type', comment: '完整圖片內容類型'
      t.bigint   'full_image_file_size', comment: '完整圖片檔案大小'
      t.datetime 'full_image_updated_at', comment: '完整圖片更新時間'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'user_coupons', force: :cascade do |t|
      t.integer  'user_id', comment: '使用者ID'
      t.integer  'coupon_id', comment: '優惠券ID'
      t.boolean  'is_vaild',                   default: true, comment: '是否有效'
      t.boolean  'is_used',                    default: false, comment: '是否已使用'
      t.boolean  'is_expired', default: false, comment: '是否已過期'
      t.datetime 'used_datetime', comment: '使用時間'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end
  end
end
