class User::Request < ActiveRecord::Base
    belongs_to :user

    has_many :request_receivers, :dependent => :destroy
    has_many :receivers, :through => :request_receivers

    def owner
        self.user
    end

    def owner_address_text
        address_text = CITY_CODE.select {|c| c[:code] == self.user.addr_city}.first[:city]
        address_text += POSTAL_CODE.select {|c| c[:code] == self.user.addr_postal}.first[:name]
        address_text += self.user.address
        address_text
    end

    def helper
        User.find(self.helper_id)
    end

    def count_reward
        self.reward = self.time
    end

end
