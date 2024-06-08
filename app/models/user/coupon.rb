class User::Coupon < ActiveRecord::Base

    belongs_to :user

    def coupon
        Coupon.find_by_id(self.coupon_id)
    end
end
