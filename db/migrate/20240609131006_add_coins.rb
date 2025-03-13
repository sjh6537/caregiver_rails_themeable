class AddCoins < ActiveRecord::Migration[7.1]
  def change
    create_table 'user_history_coins', force: :cascade do |t|
      t.integer  'user_id'
      t.integer  'category'
      t.integer  'category_id'
      t.integer  'number',                     default: 0
      t.string   'description',                default: ''
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_column :user_profiles, :coins_this_y, :integer,  default: 0
    add_column :user_profiles, :coins_next_y, :integer,  default: 0

    remove_column :user_coupons, :Exp_Date,       :datetime
    add_column    :user_coupons, :used_datetime,  :datetime

    remove_column :coupons, :number_total,    :integer
    add_column    :coupons, :number_used,     :integer, default: 0

    def self.down
      change_column :user_coupons, :is_used,  :boolean,      default: true
    end

    def self.up
      change_column :user_coupons, :is_used,  :boolean,      default: false
    end
  end
end
