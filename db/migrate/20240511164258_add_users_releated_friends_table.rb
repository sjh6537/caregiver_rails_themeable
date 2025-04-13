class AddUsersReleatedFriendsTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_users_releated_friends', force: :cascade do |t|
      t.integer  'user_id', comment: '使用者ID'
      t.integer  'friend_id', comment: '朋友ID'
      t.boolean  'block', comment: '是否封鎖', default: false
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'user_request_receivers', force: :cascade do |t|
      t.integer  'request_id', comment: '請求ID'
      t.integer  'receiver_id', comment: '接收者ID'
      t.boolean  'response', comment: '是否回應', default: false
      t.integer  'count', comment: '計數', default: 0
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end

    create_table 'request_categories', force: :cascade do |t|
      t.boolean   'is_show', comment: '是否顯示', default: false
      t.string    'text', comment: '類別名稱', limit: 30, default: '', null: false
      t.datetime  'created_at', comment: '建立時間'
      t.datetime  'updated_at', comment: '更新時間'
    end
  end
end
