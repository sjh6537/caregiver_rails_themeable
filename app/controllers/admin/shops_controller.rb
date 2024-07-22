# -*- encoding : utf-8 -*-
class Admin::ShopsController < ApplicationAdminController
    before_action :set_shop, only: [:show, :edit, :update, :destroy]

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @shops = Shop.all
    end

    def new
      @title_sub = I18n.t(:New, scope: "Title")
      @shop = Shop.new()
      respond_to do |format|
        format.html
      end
    end

    def create
      @title_sub = I18n.t(:New, scope: "Title")
      @shop = Shop.new(shop_params)
      respond_to do |format|
        if @shop.save
          add_log(ACTION_NEW,LOG_ADMIN,current_admin.id,LOG_SHOP,@shop.id)
          format.html { redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Created, scope: "Notice", name: "#{@shop.name}") }
        else
          format.html { render action: "new", alert: I18n.t(:Created_Fail, scope: "Notice", name: "#{@shop.name}") }
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
        if @shop.update(shop_params)
          add_log(ACTION_EDIT,LOG_ADMIN,current_admin.id,LOG_SHOP,@shop.id)
          format.html { redirect_to admin_shop_path(@shop.id), notice: I18n.t(:Updated, scope: "Notice", name: "#{@shop.name}") }
        else
          format.html { render action: "edit", alert: I18n.t(:Updated_Fail, scope: "Notice", name: "#{@shop.name}") }
        end
      end

    end

    def destroy
      respond_to do |format|
        add_log(ACTION_DEL,LOG_ADMIN,current_admin.id,LOG_SHOP,@shop.id)
        if @shop.destroy
          format.html { redirect_to admin_shops_path, notice: I18n.t(:Deleted, scope: "Notice", name: "#{@shop.name}") }
        else
          format.html { redirect_back fallback_location: "/", alert: I18n.t(:Deleted_Fail, scope: "Notice", name: "#{@shop.name}") }
        end
      end
    end

    private

    def set_shop
      @shop = Shop.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shop_params
      params.require(:shop).permit!
    end


    def set_breadcrumb
      @title = I18n.t(:SHOPS_TABLE, scope: "Title")
      @title_sub = nil
    end

  end
