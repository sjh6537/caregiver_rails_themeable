class AddShopColume < ActiveRecord::Migration[7.1]
  def change
    add_column    :shops,      :price,          :string,      default: nil, limit: 30
    add_column    :shops,      :category,       :integer,     default: 0
    add_column    :shops,      :service,        :string,      default: nil, limit: 50
    add_column    :shops,      :description,    :text,        default: nil
    add_column    :shops,      :latitude,       :decimal,     default: nil
    add_column    :shops,      :longitude,      :decimal,     default: nil

    create_table 'shop_images', force: :cascade do |t|
      t.integer  'shop_id'
      t.string   'image_file_name'
      t.string   'image_content_type'
      t.bigint   'image_file_size'
      t.datetime 'image_updated_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
