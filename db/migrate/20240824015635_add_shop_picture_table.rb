class AddShopPictureTable < ActiveRecord::Migration[7.1]
  def change

    create_table "shop_pictures", force: :cascade do |t|
      t.integer  "shop_id"
      t.string   "url",                   default: ""
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    remove_column :shops,      :name,     :string, limit: 30, default: ""
    remove_column :shops,      :phone,    :string, limit: 20, default: ""
    remove_column :shops,      :address,  :string, limit: 50, default: ""
    remove_column :shops,      :price,    :string, limit: 30, default: ""
    remove_column :shops,      :service,  :string, limit: 50, default: ""

    add_column    :shops,      :name,     :string, limit: 200, default: ""
    add_column    :shops,      :phone,    :string, limit: 200, default: ""
    add_column    :shops,      :address,  :string, limit: 200, default: ""
    add_column    :shops,      :price,    :string, limit: 200, default: ""
    add_column    :shops,      :service,  :string, limit: 200, default: ""
    add_column    :shops,      :opening,  :string, limit: 200, default: ""
    add_column    :shops,      :map_id,   :string, limit: 20,  default: "",    null: false

    add_index     "shops", ["map_id"], name: "index_map_id", using: :btree

  end
end
