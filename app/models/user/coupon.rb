module User
  class Coupon < ActiveRecord::Base
    belongs_to :user

    def coupon
      Coupon.find_by_id(coupon_id)
    end

    def use
      update(is_used: true, used_datetime: Time.now)
    end

    def check_vaild
      start_time = coupon.period_start
      start_time.nil? || start_time >= Time.now
    end

    def check_expired
      end_time = coupon.period_end
      (!end_time.nil? && end_time >= Time.now) || false
    end
  end
end
