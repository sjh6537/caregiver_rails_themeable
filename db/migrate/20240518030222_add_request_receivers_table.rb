class AddRequestReceiversTable < ActiveRecord::Migration[7.1]
  def change

    create_table "user_request_receivers", force: :cascade do |t|
      t.integer  "request_id"
      t.integer  "receiver_id"
      t.boolean  "response",                  default: false
      t.integer  "count" ,                    default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
