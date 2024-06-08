# -*- encoding : utf-8 -*-
class Web::CouponsController < ApplicationWebController
    before_action :set_user, only: [:show_user, :redeem]

    def show_shop
      @coupon = Coupon.find_by_id(params[:id])
      @shop = @coupon.shop
    end

    def show_user
      @coupon = @user.coupons.find_by_id(params[:id])
    end

    def redeem

    end

    private

    def set_user
        @user = current_user
    end

  end
