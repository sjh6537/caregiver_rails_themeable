class Coupon < ActiveRecord::Base

    has_many :user_coupons, :dependent => :destroy, class_name: 'User::Coupon'
    belongs_to :shop

end
