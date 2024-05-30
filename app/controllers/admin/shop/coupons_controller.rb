# -*- encoding : utf-8 -*-
class Admin::Shop::CouponsController < ApplicationAdminController
    before_action :set_coupon, only: [:show, :edit, :update, :destroy]
    before_action :set_shop, only: [:new, :create, :edit, :update, :destroy]

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @coupons = Coupon.all
    end

    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @coupon = Coupon.new()
      respond_to do |format|
        format.html
      end
    end

    def create
      @title_sub = I18n.t(:New, scope: "Title")
      @coupon = @shop.coupons.new(coupon_params)
      respond_to do |format|
        if @coupon.save
          format.html { redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Created, scope: "Notice", name: "#{@coupon.name}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{@coupon.name}") }
        end
      end
    end

    def show
      @title_sub = I18n.t(:Information, scope: "Title")
      respond_to do |format|
        format.html
      end
    end

    def edit
      @title_sub = I18n.t(:Edit, scope: "Title")
    end

    def update
      @title_sub = I18n.t(:Edit, scope: "Title")
      respond_to do |format|
        if @coupon.update(coupon_params)
          format.html { redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Updated, scope: "Notice", name: "#{@coupon.name}") }
        else
          format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@coupon.name}") }
        end
      end

    end

    def destroy
      respond_to do |format|
        if @coupon.destroy
          format.html { redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Deleted, scope: "Notice", name: "#{@coupon.name}") }
        else
          format.html { redirect_back fallback_location: "/", alert: I18n.t(:Deleted_Fail, scope: "Notice", name: "#{@coupon.name}") }
        end
      end
    end

    private
    def set_shop
      @shop = Shop.find_by_id(params[:shop_id])
    end

    def set_coupon
      @coupon = Coupon.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coupon_params
      params.require(:coupon).permit!
    end


    def set_breadcrumb
      @title = I18n.t(:COUPONS, scope: "Title")
      @title_sub = nil
    end

  end
