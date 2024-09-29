# -*- encoding : utf-8 -*-
class Web::ShopsController < ApplicationWebController
    layout :resolve_layout

    def index
      @title_sub = I18n.t(:Table, scope: "Title")
      @shops = Shop.where("latitude IS NOT NULL")
      @shop = Shop.first
    end

    def show


    end


    private

    def resolve_layout
      case action_name
      when "index"
        "map"
      else
        "valex"
      end
    end

    def set_breadcrumb
      @title = I18n.t(:SHOPS, scope: "Title")
      @title_sub = nil
    end

  end
