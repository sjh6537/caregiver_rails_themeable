class AddCouponAssetImage < ActiveRecord::Migration[7.1]
  def change

    add_column :coupons, :image_file_name, :string
    add_column :coupons, :image_content_type, :string
    add_column :coupons, :image_file_size, :bigint
    add_column :coupons, :image_updated_at, :datetime

    add_column :coupons, :full_image_file_name, :string
    add_column :coupons, :full_image_content_type, :string
    add_column :coupons, :full_image_file_size, :bigint
    add_column :coupons, :full_image_updated_at, :datetime

  end
end
