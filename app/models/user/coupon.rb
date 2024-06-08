class User::Coupon < ActiveRecord::Base

    belongs_to :user

    def coupon
        Coupon.find_by_id(self.coupon_id)
    end

    def use
        self.update(is_used: true, used_datetime: Time.now)
    end

end
