class AddUserReleatedCaregiver < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_users_releated_caregivers', force: :cascade do |t|
      t.integer  'cared_id'
      t.integer  'caregiver_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
