class ModifyScheduleTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'schedule_messages', force: :cascade do |t|
      t.string   'job_id', comment: '工作ID'
      t.integer  'message_type', default: 0, comment: '訊息類型'
      t.text     'user_ids', comment: '使用者ID列表'
      t.string   'schedule_name', comment: '排程名稱'
      t.string   'message_text', comment: '訊息內容'
      t.datetime 'scheduled_time', comment: '預定時間'
      t.datetime 'execution_time', comment: '執行時間'
      t.integer  'status', default: 0, comment: '狀態'
      t.datetime 'created_at', comment: '建立時間'
      t.datetime 'updated_at', comment: '更新時間'
    end
  end
end
