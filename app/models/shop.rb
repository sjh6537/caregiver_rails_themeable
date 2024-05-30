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

end
