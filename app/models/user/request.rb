class User::Request < ActiveRecord::Base
    include ApplicationHelper

    belongs_to :helper , class_name: 'User' , :foreign_key => "helper_id" , optional: true
    belongs_to :owner  , class_name: 'User' , :foreign_key => "user_id"

    has_many :request_receivers, :dependent => :destroy
    has_many :receivers, :through => :request_receivers

    def date
        if self.request_date.nil?
            ""
        else
            "#{self.request_date.strftime('%Y/%m/%d - %R')}"
        end    
    end

    def contact_info_non_accept
        self.contact_info[0...4] + "-xxxxxx"
    end

    def content_non_accept
        text = "<p class='tx-orange'><strong>#{self.title}</strong>"
        text += "<p>時間 : #{self.request_date.strftime('%Y/%m/%d - %R')}, 約 #{self.request_time} 小時"
        text += "<p>地點 : #{get_city(self.location_city)}  #{get_postal(self.location_postal)}"
        text += "<p>聯絡方式 : #{contact_info_non_accept}"
        text += "<p>描述 : #{self.descrition}"
        text
    end

    def content_accept
        text = "<p class='tx-orange'><strong>#{self.title}</strong>"
        text += "<p>時間 : #{self.request_date.strftime('%Y/%m/%d - %R')}, 約 #{self.request_time} 小時"
        text += "<p>地點 : #{get_city(self.location_city)}  #{get_postal(self.location_postal)} #{self.location}"
        text += "<p>聯絡方式 : #{self.contact_info}"
        text += "<p>描述 : #{self.descrition}"
        text
    end

    ##Time.now.localtime.strftime('%Y-%m-%d %R')
    def count_reward
        self.reward = self.time
    end

end
