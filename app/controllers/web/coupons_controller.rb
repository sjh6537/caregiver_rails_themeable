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

    private

    def set_user
        @user = current_user
    end

  end
