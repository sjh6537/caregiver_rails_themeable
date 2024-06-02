class User < ActiveRecord::Base
    validates :account, presence: true, uniqueness: true

    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :authentication_keys => [:oauth_token]

    validates_presence_of :account, :case_sensitive => true, length: {maximun: 50}

    has_one :profile, :dependent => :destroy, class_name: 'User::Profile'

    has_many :users_related_friends, :dependent => :destroy, class_name: 'User::UsersReleatedFriends'
    has_many :friends, :through => :users_related_friends, :source => :user, foreign_key: 'friend_id', primary_key: 'user_id'
    has_many :requests, :dependent => :destroy, class_name: 'User::Request'

    def add_friend(friend_id)
      if (self.friends.where(id: friend_id).empty?)
        User::UsersReleatedFriends.create(user_id: self.id, friend_id: friend_id)
      end
    end

    def del_friend(friend_id)
      if (!self.friends.where(id: friend_id).empty?)
        User::UsersReleatedFriends.where(user_id: self.id, friend_id: friend_id).destroy_all
      end
    end

    def add_each_friends(friend_id)
      if (self.friends.where(id: friend_id).empty?)
        User::UsersReleatedFriends.create(user_id: self.id, friend_id: friend_id)
      end
      if (User.find(friend_id).friends.where(id: self.id).empty?)
        User::UsersReleatedFriends.create(user_id: friend_id, friend_id: self.id)
      end
    end

    def accept_requests
      User::Request.where("helper_id == #{self.id}")
    end

    def accept_requests
      User::Request.where("helper_id == #{self.id}")
    end

    def request_accept_count(friend_id)
      self.requests.where(helper_id: friend_id).count
    end

    def requests_new
      self.requests.where("status < ?", REQUEST_FINISH )
    end

    def requests_finish
      self.requests.where("status = ?", REQUEST_FINISH )
    end

    def requests_expired
      self.requests.where("status = ?", REQUEST_EXPIRED )
    end

    def address_text
      if !self.addr_city? || !self.addr_postal? || !self.address?
        return
      end
      print "address:#{self.address}"
      address_text = CITY_CODE.select {|c| c[:code] == self.addr_city}.first[:city]
      address_text += POSTAL_CODE.select {|c| c[:code] == self.addr_postal}.first[:name]
      address_text += self.address
      address_text
    end

    def line_token
      self.profile.line_token
    end

    def line_image
      if self.profile.line_image.nil? or self.profile.line_image == ""
        "/assets/valex/img/faces/alien.png"
      else
        self.profile.line_image
      end
    end

    def line_name(length = 15)
      name = self.profile.line_name
      name.size > length ? [name[0,length],".."].join(".") : name
    end

    def line_phone
      self.profile.line_phone
    end

    def line_email
      self.profile.line_email
    end

    def birthday_date
      self.birthday.strftime('%Y/%m/%d')
    end

    def self.find_for_authentication(warden_conditions)
        warden_conditions[:account].upcase!
        where(customer_id: warden_conditions[:customer_id], account: warden_conditions[:account]).first
    end

    protected

    # From Devise module Validatable
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

end
