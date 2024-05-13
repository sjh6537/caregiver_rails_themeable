class User < ActiveRecord::Base
    validates :account, presence: true, uniqueness: true

    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :authentication_keys => [:oauth_token]

    validates_presence_of :account, :case_sensitive => true, length: {maximun: 50}

    has_one :profile, :dependent => :destroy, class_name: 'User::Profile'

    has_many :users_related_friends, :dependent => :destroy, class_name: 'User::UsersReleatedFriends'
    has_many :friends, :through => :users_related_friends, :source => :user, foreign_key: 'friend_id', primary_key: 'user_id'
    has_many :requests, :dependent => :destroy, class_name: 'User::Request'

    def address_text
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

    def line_name
      self.profile.line_name
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
