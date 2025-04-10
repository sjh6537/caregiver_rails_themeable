class AddUsersReleatedFriendsTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_users_releated_friends', force: :cascade do |t|
      t.integer  'user_id'
      t.integer  'friend_id'
      t.boolean  'block', default: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    create_table 'user_request_receivers', force: :cascade do |t|
      t.integer  'request_id'
      t.integer  'receiver_id'
      t.boolean  'response',                  default: false
      t.integer  'count' ,                    default: 0
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    create_table 'request_categories', force: :cascade do |t|
      t.boolean   'is_show',      default: false
      t.string    'text',         limit: 30, default: '', null: false
      t.datetime  'created_at'
      t.datetime  'updated_at'
    end
  end
end
