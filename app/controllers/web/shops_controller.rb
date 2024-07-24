# -*- encoding : utf-8 -*-
class Web::ShopsController < ApplicationWebController

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @shops = Shop.all
      @shop = Shop.first
    end

    def show


    end


    private

    def set_breadcrumb
      @title = I18n.t(:SHOPS, scope: "Title")
      @title_sub = nil
    end

  end
