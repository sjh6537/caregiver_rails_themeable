class AddCouponColumn < ActiveRecord::Migration[7.1]

  def self.down
    change_column :coupons, :comment, :string,      default: "", limit: 50
    remove_column :coupons, :rule,    :string,      default: "", limit: 30
    remove_column :coupons, :redeem,  :integer,     default: nil
  end

  def self.up
    change_column :coupons, :comment, :text,        default: "", limit: 1000
    add_column    :coupons, :rule,    :string,      default: "", limit: 30
    add_column    :coupons, :redeem,  :integer,     default: nil
  end

end
