class User::Coupon < ActiveRecord::Base

    belongs_to :user
    belongs_to :coupon

    def image
        self.coupon.image
    end

    def full_image
        self.coupon.full_image
    end

end
