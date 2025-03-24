class DailyCheck
  include Sidekiq::Worker
  include LineHelper
  sidekiq_options retry: false

  def perform
    User::Request.all.map do |request|
      if request.status < REQUEST_FINISH && request.is_finish
        request.update(status: REQUEST_FINISH)
        request.helper.coins_get(1 , COINS_GET_REQUEST , request.id , '派工完成獲得柑幣')
      elsif request.status < REQUEST_FINISH && request.is_expired
        request.update(status: REQUEST_EXPIRED)
      end
    end

    User::Coupon.all.map do |coupon|
      coupon.update(is_vaild: true) if coupon.is_vaild == false && coupon.check_vaild == true

      coupon.update(is_expired: true) if coupon.is_expired == false && coupon.is_expired == true
    end
  end
end
