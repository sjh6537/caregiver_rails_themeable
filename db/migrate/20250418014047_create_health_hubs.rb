class CreateHealthHubs < ActiveRecord::Migration[7.1]
  def change
    create_table :health_hubs do |t|
      t.integer :community_id, comment: '社區ID'
      t.boolean :enable, default: true, null: false, comment: '啟用'
      t.datetime :purchase_date, comment: '購買日期' # 使用 datetime 類型
      t.string :brand, limit: 50, comment: '品牌'
      t.string :address, limit: 200, comment: '地址'
      t.string :latitude, limit: 20, comment: '緯度'
      t.string :longitude, limit: 20, comment: '經度'
      t.string :status, limit: 50, comment: '狀態'
      t.string :note, limit: 200, comment: '備註'
      t.string :comment, limit: 200, comment: '健康中心備註'
      t.timestamps # 自動加入 created_at 和 updated_at
    end
    add_index :health_hubs, :community_id, name: 'index_health_hubs_on_community_id'
  end
end
