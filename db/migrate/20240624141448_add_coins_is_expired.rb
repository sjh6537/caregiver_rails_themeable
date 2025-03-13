class AddCoinsIsExpired < ActiveRecord::Migration[7.1]
  def change
    add_column :user_coupons, :is_expired, :boolean, default: false
  end
end
