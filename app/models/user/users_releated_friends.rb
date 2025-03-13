module User
  class UsersReleatedFriends < ActiveRecord::Base
    belongs_to :user, foreign_key: 'friend_id'
  end
end
