class ModifyScheduleTable < ActiveRecord::Migration[7.1]
  def self.down
    drop_table :schedule_messages

    create_table 'schedule_events', force: :cascade do |t|
      t.integer 'schedule_id'
      t.string 'job_id'
      t.string 'message_text'
      t.string 'message_image'
      t.integer 'schedule_type'
      t.string 'schedule_name'
      t.string 'recipient'
      t.datetime 'scheduled_time'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end

  def self.up
    drop_table :schedule_events

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
