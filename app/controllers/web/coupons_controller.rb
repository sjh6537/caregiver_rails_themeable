# -*- encoding : utf-8 -*-
class Web::CouponsController < ApplicationWebController
    before_action :set_user, only: [:show_shop, :show_user, :redeem, :use]

    def show_shop
      @coupon = Coupon.find_by_id(params[:id])
      @shop = @coupon.shop
    end

    def show_user
      @usercoupon = @user.coupons.find_by_id(params[:id])
      @coupon = @usercoupon.coupon
      @shop = @coupon.shop
      @time_left = (@usercoupon.used_datetime + 30*60 - Time.now).to_i
    end

    def redeem
      @coupon = Coupon.find_by_id(params[:id])
      if @coupon.number_stock > 1
        if @user.redeem_coupon(@coupon)
          redirect_to web_user_coupons_path, notice: I18n.t("Notify.Note.Redeem_success", name: "#{@coupon.name}")
        else
          redirect_back fallback_location: "/", alert: I18n.t("Notify.Note.Redeem_fail_coin_not_enough", name: "#{@coupon.name}")
        end
      else
        redirect_back fallback_location: "/", alert: I18n.t("Notify.Note.Redeem_fail_coupon_not_enough", name: "#{@coupon.name}")
      end
    end

    def use
      @usercoupon = User::Coupon.find_by_id(params[:id])
      @usercoupon.use
      redirect_to web_coupons_show_user_path(@usercoupon.id)
    end

    private

    def set_user
        @user = current_user
    end

  end
