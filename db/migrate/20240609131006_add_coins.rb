class AddCoins < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_history_coins', force: :cascade do |t|
      t.integer  'user_id', comment: '使用者 ID'
      t.integer  'category', comment: '類別'
      t.integer  'category_id', comment: '類別 ID'
      t.integer  'number', default: 0, comment: '數量'
      t.string   'description', default: '', comment: '描述'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'history_logs', force: :cascade do |t|
      t.integer  'source', comment: '來源類型'
      t.integer  'source_id', comment: '來源 ID'
      t.integer  'target', comment: '目標類型'
      t.integer  'target_id', comment: '目標 ID'
      t.integer  'action', comment: '動作類型'
      t.string   'data',                limit: 30, default: nil, comment: '額外資料'
      t.string   'description',         limit: 50, default: nil, comment: '描述文字'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end
  end
end
