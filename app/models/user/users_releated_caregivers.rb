module User
  class UsersReleatedCaregivers < ActiveRecord::Base
    belongs_to :caregiver, class_name: 'User', foreign_key: 'caregiver_id'
    belongs_to :cared, class_name: 'User', foreign_key: 'cared_id'
  end
end
