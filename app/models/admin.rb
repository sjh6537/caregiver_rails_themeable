class Admin < ActiveRecord::Base
    before_save :reset_super_admin
    before_update :reset_super_admin
  
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:account]
  
    validates_presence_of :account, :email
    validates_uniqueness_of :account, :case_sensitive => false
    validates_uniqueness_of :email, :case_sensitive => false
  
    def type
      if self.super_admin
        I18n.t(:Super_Admin , scope: "Sidebar")
      else
        I18n.t(:Admin , scope: "Sidebar")
      end
    end
  
    def status
      if self.enable?
        I18n.t(:Active, scope: "Table")
      else
        I18n.t(:Banned, scope: "Table")
      end
    end
  
    def active_for_authentication?
      self.enable?
    end
  
    def inactive_message
      "您的帳號目前停用中。"
    end
    
    def default_name
      self.name || self.account.camelize
    end
  
    def reset_super_admin
      if Admin.count == 0
        self.super_admin = true
      elsif self.id == 1
        self.super_admin = true
      else
        self.super_admin = false
      end
    end
  
  end
  