class User < ActiveRecord::Base
    before_save :change_case
  
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :authentication_keys => [:account, :customer_id]
  
    validates_presence_of     :password, if: :password_required?
    validates_confirmation_of :password, if: :password_required?
    validates_length_of       :password, within: 6..128, allow_blank: false, if: :password_required?
  
    validates_presence_of :account, :case_sensitive => true, length: {maximun: 20}
    validates_presence_of :name, length: {maximun: 20}
    validates :account, :uniqueness => {:scope => :customer_id}
  
    def notify_token
      self.line_notify_token
    end
  
    def change_case
      self.account.upcase! if self.account
      self.email.downcase! if self.email
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
  