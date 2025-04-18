class CreateCaredFacilitiesTables < ActiveRecord::Migration[7.1]
  def change
    # 建立照護設施類型資料表
    create_table :cared_facility_types do |t|
      t.string :name, limit: 50, null: false, comment: '照護設施類型名稱'
      t.string :description, limit: 100, comment: '照護設施類型描述'
      t.string :icon, limit: 50, comment: '照護設施類型圖示'
      t.boolean :enabled, default: true, comment: '是否啟用'
      t.integer :sort_order, default: 0, comment: '排序'
      t.string :notes, comment: '備註', limit: 200
    end

    # 建立照護設施資料表
    create_table :cared_facilities do |t|
      t.string :name, limit: 50, null: false, comment: '照護設施名稱'
      t.string :description, limit: 200, comment: '照護設施描述'
      t.string :brand, limit: 50, comment: '品牌'
      t.string :serial_number, limit: 50, comment: '序號'
      t.string :model, limit: 50, comment: '型號'
      t.boolean :inuse, default: true, null: false, comment: '是否使用中'
      t.integer :cared_user_info_id, comment: '照護使用者資訊ID'
      t.integer :cared_facility_type_id, comment: '照護設施類型ID'
      t.boolean :enabled, default: true, comment: '是否啟用'
      t.string :latitude, comment: '緯度', limit: 20
      t.string :longitude, comment: '經度', limit: 20
      t.datetime :activation_date, comment: '啟用日期'
      t.datetime :deactivation_date, comment: '停用日期'
      t.datetime :last_updated_date, comment: '最後更新日期'
      t.string :note, limit: 100, comment: '備註'
      t.timestamps # 自動加入 created_at 和 updated_at
    end

    # 建立照護設施事件類型資料表
    create_table :cared_facility_event_types do |t|
      t.string :name, limit: 50, null: false, comment: '照護設施事件類型名稱'
      t.string :description, limit: 100, comment: '照護設施類事件描述'
      t.string :icon, limit: 50, comment: '照護設施事件圖示'
      t.boolean :enabled, default: true, comment: '是否啟用'
      t.integer :sort_order, default: 0, comment: '排序'
      t.string :notes, comment: '備註', limit: 200
    end

    # 建立照護設施事件資料表
    create_table :cared_facility_events do |t|
      t.integer :cared_facility_event_type_id, comment: '照護設施事件類型ID'
      t.integer :cared_facility_id, comment: '照護設施ID'
      t.integer :cared_user_info_id, comment: '照護使用者資訊ID'
      t.integer :processed_by, comment: '處理者ID'
      t.boolean :processed, default: false, comment: '是否已處理'
      t.datetime :processed_at, comment: '處理時間'
      t.string :processed_note, limit: 200, comment: '處理說明'
      # 使用 t.timestamp 替代 created_at，因為圖片中只有這個時間欄位
      t.timestamp :created_at, default: -> { 'CURRENT_TIMESTAMP' }, null: false, comment: '建立時間'
    end

    # 加入索引以提高查詢效能
    add_index :cared_facilities, :cared_user_info_id
    add_index :cared_facilities, :cared_facility_type_id
    add_index :cared_facility_events, :cared_facility_event_type_id
    add_index :cared_facility_events, :cared_facility_id
  end
end
