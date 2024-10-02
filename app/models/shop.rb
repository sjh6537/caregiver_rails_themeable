class Shop < ActiveRecord::Base
    include ApplicationHelper

    validates :map_id, presence: true, uniqueness: true

    has_many :coupons, :dependent => :destroy
    has_many :pictures, :dependent => :destroy, class_name: 'ShopPicture', foreign_key: 'shop_id'

    def city
      get_city(self.addr_city)
    end

    def postal
      get_postal(self.addr_postal)
    end

    def all_address
      city.to_s + postal.to_s + self.address.to_s
    end

    def show_text
      if (self.is_show == true)
        "顯示"
      else
        "不顯示"
      end
    end

    def category_name
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:name]
        end
      end
        return "others"
    end

    def category_text
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:category]
        end
      end
        return "其他"
    end

    def map_icon
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:icon]
        end
      end
        return SHOP_CATEGORY_CODE[0][:icon]
    end

    def html_font
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:heml_font]
        end
      end
        return SHOP_CATEGORY_CODE[0][:heml_font]
    end

    def category_name
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:name]
        end
      end
        return SHOP_CATEGORY_CODE[0][:name]
    end

    def html_index_list(index)
      html = ""
      html += '<li class="list-item">'
      html += '<div class="avatar avatar-md rounded-circle bg-' + self.category_name +  ' ">' + self.html_font + '</div>'
      html += '<div class=" ml-2">'
      html += '<a class="tx-15 mb-1 font-weight-medium shop-click" href="#" data-value="' + index.to_s + '" >' + self.name.to_s + '</a><h7 class="mb-0 text-muted tx-13"> ' + self.service.to_s + '</h7>'
      html += '<p class="mb-0 text-primary tx-17">' + self.phone.to_s + ' ▪️ ' + self.address.to_s + '</p>'
      html += '</div>'
      html += '</li>'
    end
end
