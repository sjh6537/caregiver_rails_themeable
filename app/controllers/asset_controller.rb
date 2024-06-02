# -*- encoding : utf-8 -*-
class AssetController < ApplicationController

    def coupons
        send_file Rails.root.join('images/coupons/',params[:id],'image/',params[:filename] + "." + params[:format])
    end

    def coupons_full
        send_file Rails.root.join('images/coupons/',params[:id],'full_image/',params[:filename] + "." + params[:format])
    end

  end
