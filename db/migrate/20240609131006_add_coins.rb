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
      t.integer  'source'
      t.integer  'source_id'
      t.integer  'target'
      t.integer  'target_id'
      t.integer  'action'
      t.string   'data',                limit: 30, default: nil
      t.string   'description',         limit: 50, default: nil
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
