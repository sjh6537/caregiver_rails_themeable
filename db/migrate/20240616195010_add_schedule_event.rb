class AddScheduleEvent < ActiveRecord::Migration[7.1]
  def change
    create_table "schedule_events", force: :cascade do |t|
      t.integer   "schedule_id"
      t.string    "job_id"
      t.string    "message_text"
      t.string    "message_image"
      t.integer   "schedule_type"
      t.string    "schedule_name"
      t.string    "recipient"
      t.datetime  "scheduled_time"
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end

  end
end
