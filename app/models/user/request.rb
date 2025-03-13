class User::Request < ActiveRecord::Base
    after_create :send_message_new
    after_update :check_agree

    include ApplicationHelper
    include LineHelper

    validates_presence_of :request_date

    belongs_to :helper , class_name: 'User' , :foreign_key => "helper_id" , optional: true
    belongs_to :owner  , class_name: 'User' , :foreign_key => "user_id"

    has_many :request_receivers, :dependent => :destroy
    has_many :receivers, :through => :request_receivers

    def is_finish
        self.request_date < Time.now && !self.helper.nil?
    end

    def is_expired
        self.request_date < Time.now
    end

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

    def check_agree
        if !self.helper.nil? && self.status == REQUEST_ACCEPTED
            message_push(self.owner.account , "Hi , 你的派工「#{self.title}」已被#{self.helper.name}接受")
            #message_push(self.helper.account , "Hi , 你已接受#{self.owner.name}的派工「#{self.title}」")
        end
    end

    def send_message_new
        if !self.owner.nil?
            message_push(self.owner.account , "Hi , 你新增一個派工「#{self.title}」")
            job_id = RequestNotify.perform_at(self.request_date-60*60, self.id)
        end
    end

    ##Time.now.localtime.strftime('%Y-%m-%d %R')
    def count_reward
        self.reward = self.time
    end

end
