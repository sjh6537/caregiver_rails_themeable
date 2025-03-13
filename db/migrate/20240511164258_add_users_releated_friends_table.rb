class AddUsersReleatedFriendsTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_users_releated_friends', force: :cascade do |t|
      t.integer  'user_id'
      t.integer  'friend_id'
      t.boolean  'block', default: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
