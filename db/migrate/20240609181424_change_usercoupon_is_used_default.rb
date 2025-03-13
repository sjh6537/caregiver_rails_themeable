class ChangeUsercouponIsUsedDefault < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_coupons, :is_used, :boolean, default: true
    add_column    :user_coupons, :is_used, :boolean, default: false
  end
end
