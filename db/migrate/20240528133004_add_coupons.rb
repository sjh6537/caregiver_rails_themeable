class AddCoupons < ActiveRecord::Migration[7.1]
  def change

    create_table "shops", force: :cascade do |t|
      t.string   "name",                       default: "", limit: 30
      t.boolean  "is_show",                    default: false
      t.string   "phone",                      default: "", limit: 20
      t.string   "address",                    default: "", limit: 50
      t.integer  "addr_city",                  default: 0
      t.integer  "addr_postal",                default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "coupons", force: :cascade do |t|
      t.integer  "shop_id"
      t.string   "name",                       default: "", limit: 30
      t.string   "discount",                   default: "", limit: 20
      t.string   "comment",                    default: "", limit: 50
      t.boolean  "is_vaild",                   default: true
      t.integer  "number_total",               default: 0
      t.integer  "number_stock",               default: 0
      t.datetime "period_start"
      t.datetime "period_end"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "user_coupons", force: :cascade do |t|
      t.integer  "user_id"
      t.integer  "coupon_id"
      t.boolean  "is_vaild",                   default: true
      t.boolean  "is_used",                    default: true
      t.datetime "Exp_Date"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
