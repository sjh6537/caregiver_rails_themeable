class AddRequestCategory < ActiveRecord::Migration[7.1]
  def change
    create_table 'request_categories', force: :cascade do |t|
      t.boolean   'is_show',      default: false
      t.string    'text',         limit: 30, default: '', null: false
      t.datetime  'created_at'
      t.datetime  'updated_at'
    end

    RequestCategory.create(is_show: true, text: '煮飯')
    RequestCategory.create(is_show: true, text: '購物')
    RequestCategory.create(is_show: true, text: '洗衣')
    RequestCategory.create(is_show: true, text: '水電修理')
    RequestCategory.create(is_show: true, text: '看醫生')
    RequestCategory.create(is_show: true, text: '醫囑提醒')
    RequestCategory.create(is_show: true, text: '寵物陪伴')
    RequestCategory.create(is_show: true, text: '外出協助')
  end
end
