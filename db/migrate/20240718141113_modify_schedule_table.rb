class ModifyScheduleTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'schedule_messages', force: :cascade do |t|
      t.string   'job_id'
      t.integer  'message_type', default: 0
      t.text     'user_ids'
      t.string   'schedule_name'
      t.string   'message_text'
      t.datetime 'scheduled_time'
      t.datetime 'execution_time'
      t.integer  'status', default: 0
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
