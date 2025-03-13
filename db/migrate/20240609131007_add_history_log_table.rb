class AddHistoryLogTable < ActiveRecord::Migration[7.1]
  def change
    create_table 'history_logs', force: :cascade do |t|
      t.integer  'source'
      t.integer  'source_id'
      t.integer  'target'
      t.integer  'target_id'
      t.integer  'action'
      t.string   'data',                limit: 30, default: nil
      t.string   'description',         limit: 50, default: nil
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
