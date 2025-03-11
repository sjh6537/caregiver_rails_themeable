class AddCouponColumn < ActiveRecord::Migration[7.1]

  def self.down
    change_column :coupons, :comment, :string,      default:"", limit: 50
    remove_column :coupons, :rule,    :string,      default: "", limit: 30
    remove_column :coupons, :redeem,  :integer,     default: nil
  end

  def self.up
    # 先移除欄位然後重新添加，避免使用 change_column 的限制
    remove_column :coupons, :comment
    add_column :coupons, :comment, :text, null: true, limit: 1000
     
    add_column    :coupons, :rule,    :string,      default: "", limit: 30
    add_column    :coupons, :redeem,  :integer,     default: nil
  end

end
