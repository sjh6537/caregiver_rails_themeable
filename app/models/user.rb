class User < ActiveRecord::Base
  after_destroy :check_sidekiq_jobs
  validates :account, presence: true, uniqueness: true

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, authentication_keys: [:oauth_token]

  validates_presence_of :account, case_sensitive: true, length: { maximun: 50 }

  has_one :profile, dependent: :destroy, class_name: 'User::Profile'

  has_many :careds_related, dependent: :destroy, class_name: 'User::UsersReleatedCaregivers',
                            foreign_key: 'caregiver_id'
  has_many :careds, through: :careds_related, source: :cared, foreign_key: 'cared_id',
                    primary_key: 'caregiver_id'
  has_many :caregivers_related, dependent: :destroy, class_name: 'User::UsersReleatedCaregivers',
                                foreign_key: 'cared_id'
  has_many :caregivers, through: :caregivers_related, source: :caregiver, foreign_key: 'caregiver_id' ,
                        primary_key: 'cared_id'

  has_many :users_related_friends, dependent: :destroy, class_name: 'User::UsersReleatedFriends'
  has_many :friends, through: :users_related_friends, source: :user, foreign_key: 'friend_id',
                     primary_key: 'user_id'
  has_many :requests, dependent: :destroy, class_name: 'User::Request'
  has_many :coupons, dependent: :destroy, class_name: 'User::Coupon'
  has_many :history_coins, dependent: :destroy, class_name: 'User::HistoryCoin'
  has_many :health_reports, dependent: :destroy, class_name: 'User::HealthReport'
  has_many :fitness_reports, dependent: :destroy, class_name: 'User::FitnessReport'
  has_many :fitness_device_usages, dependent: :destroy
  has_many :fitness_devices, dependent: :nullify

  belongs_to :community , optional: true , class_name: 'Community'

  has_many :fitness_devices
  has_many :cared_facilities, foreign_key: 'cared_user_info_id'

  def coins
    profile.coins_this_y
  end

  def count_coins
    coins = 0
    history_coin.map do |history|
      if history.category < COINS_USE_CATEGORY
        coins += history.number
      else
        coins -= history.number
      end
    end
    coins
  end

  def add_friend(friend_id)
    return unless friends.where(id: friend_id).empty?

    User::UsersReleatedFriends.create(user_id: id, friend_id: friend_id)
  end

  def del_friend(friend_id)
    return if friends.where(id: friend_id).empty?

    User::UsersReleatedFriends.where(user_id: id, friend_id: friend_id).destroy_all
  end

  def add_each_friends(friend_id)
    return unless friend_id != id

    User::UsersReleatedFriends.create(user_id: id, friend_id: friend_id) if friends.where(id: friend_id).empty?
    return unless User.find(friend_id).friends.where(id: id).empty?

    User::UsersReleatedFriends.create(user_id: friend_id, friend_id: id)
  end

  def accept_requests
    User::Request.where("helper_id = #{id}")
  end

  def accept_requests_finish
    User::Request.where("helper_id = #{id} AND request_date < ?", Time.now)
  end

  def accept_requests_new_and_today
    User::Request.where("helper_id = #{id} AND request_date > ?", Date.today)
  end

  def request_accept_count(friend_id)
    requests.where(helper_id: friend_id).count
  end

  def requests_new_and_today
    # self.requests.where("status < ?", REQUEST_FINISH )
    requests.where('request_date > ?', Date.today)
  end

  def requests_new
    # self.requests.where("status < ?", REQUEST_FINISH )
    requests.where('request_date > ?', Time.now)
  end

  def requests_finish
    # self.requests.where("status = ?", REQUEST_FINISH )
    requests.where('request_date < ? AND helper_id IS NOT NULL ', Time.now)
  end

  def requests_expired
    # self.requests.where("status = ?", REQUEST_EXPIRED )
    requests.where('request_date < ? AND helper_id IS NULL ', Time.now)
  end

  def address_text
    return if !addr_city? || !addr_postal? || !address?

    address_text = CITY_CODE.select { |c| c[:code] == addr_city }.first[:city]
    address_text += POSTAL_CODE.select { |c| c[:code] == addr_postal }.first[:name]
    address_text += address
    address_text
  end

  def line_token
    profile.line_token
  end

  def line_image
    if profile.line_image.nil? or profile.line_image == ''
      '/assets/valex/img/faces/alien.png'
    else
      profile.line_image
    end
  end

  def line_name(length = 15)
    name = profile.line_name
    name.size > length ? [name[0, length], '..'].join('.') : name
  end

  def line_phone
    profile.line_phone
  end

  def line_email
    profile.line_email
  end

  def self.find_for_authentication(warden_conditions)
    warden_conditions[:account].upcase!
    where(customer_id: warden_conditions[:customer_id], account: warden_conditions[:account]).first
  end

  def coins_get(coins , coins_source_type , coins_source_id , description)
    current_coins = self.coins
    profile.update(coins_this_y: current_coins + coins)
    history_coins.create(category: coins_source_type, category_id: coins_source_id, number: coins,
                         description: description)
  end

  def coins_use(coins , coins_source_type , coins_source_id , description)
    current_coins = self.coins
    profile.update(coins_this_y: current_coins - coins)
    history_coins.create(category: coins_source_type, category_id: coins_source_id, number: coins,
                         description: description)
  end

  def redeem_coupon(shop_coupon)
    user_coins = coins
    redeem_coins = shop_coupon.redeem
    if user_coins >= redeem_coins
      shop_coupon.update(number_used: shop_coupon.number_used + 1, number_stock: shop_coupon.number_stock - 1)
      user_coupon = coupons.create(coupon_id: shop_coupon.id)
      coins_use(redeem_coins , COINS_USE_COUPON , user_coupon.id ,
                I18n.t('Notify.Note.Redeem_success', name: "#{shop_coupon.name}"))
      true
    else
      false
    end
  end

  protected

  # From Devise module Validatable
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def check_sidekiq_jobs
    Sidekiq::ScheduledSet.new.each do |job|
      next unless job.klass == 'NotifySender' && job.args[2].to_i == NOTIFY_SEND_TYPE_GROUP

      find = false
      job.args[0].each do |g_id|
        unless Group.find_by_id(g_id.to_i).nil?
          find = true
          break
        end
      end
      if find == false
        # can not find job group
        job.delete
      end
    end
  end
end
