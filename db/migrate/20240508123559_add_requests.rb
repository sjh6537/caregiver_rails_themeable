class AddRequests < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_requests', force: :cascade do |t|
      t.integer  'user_id'
      t.boolean  'enable',                     default: true
      t.integer  'status',                     default: 0
      t.integer  'helper_id',                  default: nil
      t.integer  'category',                   default: 0
      t.string   'title',                      limit: 30, default: ''
      t.string   'location',                   limit: 30, default: ''
      t.integer  'location_city',              default: 0
      t.integer  'location_postal',            default: 0
      t.string   'contact_info',               limit: 30, default: ''
      t.string   'description',                limit: 300, default: '', null: false
      t.datetime 'request_date'
      t.integer  'request_time'
      t.integer  'reward',                     default: 1
      t.boolean  'reward_status',              default: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    create_table 'user_request_receivers', force: :cascade do |t|
      t.integer  'request_id'
      t.integer  'user_id'
      t.integer  'consider', default: 0
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
