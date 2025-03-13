class User::Coupon < ActiveRecord::Base

    belongs_to :user

    def coupon
        Coupon.find_by_id(self.coupon_id)
    end

    def use
        self.update(is_used: true, used_datetime: Time.now)
    end

    def check_vaild
        start_time = self.coupon.period_start
        if start_time.nil?
            true
        elsif start_time >= Time.now
            true
        else
            false
        end
    end

    def check_expired
        end_time = self.coupon.period_end
        if !end_time.nil? && end_time >= Time.now
            true
        else
            false
        end
    end
end
