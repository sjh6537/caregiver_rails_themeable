class Shop < ActiveRecord::Base
    include ApplicationHelper

    has_many :coupons, :dependent => :destroy

    def city
      get_city(self.addr_city)
    end

    def postal
      get_postal(self.addr_postal)
    end

    def all_address
      city + postal + self.address
    end

    def show_text
      if (self.is_show == true)
        "顯示"
      else
        "不顯示"
      end
    end

    def category_text
      SHOP_CATEGORY_CODE.map do |c|
        if self.category == c[:code]
          return c[:category]
        end
      end
        return "其他"
    end

end
