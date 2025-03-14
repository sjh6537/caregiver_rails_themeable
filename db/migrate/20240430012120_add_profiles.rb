class AddProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_profiles', force: :cascade do |t|
      t.integer  'user_id'
      t.string   'line_uid', default: '', null: false
      t.text 'line_token', null: false
      t.string 'line_name'
      t.text 'line_image'
      t.string   'line_phone'
      t.string   'line_email'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'user_profiles', [:line_uid], unique: true, using: :btree
  end
end
