class Community < ApplicationRecord
  # Validations
  # validates :sn, presence: true, uniqueness: true, length: { maximum: 20 }
  # validates :name, presence: true, length: { maximum: 50 }
  # validates :name_eng, length: { maximum: 100 }, allow_blank: true
  # validates :description, length: { maximum: 50 }, allow_blank: true
  # validates :agreement_path, length: { maximum: 200 }, allow_blank: true
  # validates :token, uniqueness: true, length: { maximum: 200 }, allow_blank: true
  # validates :logo, length: { maximum: 200 }, allow_blank: true
  # validates :status, length: { maximum: 50 }, allow_blank: true
  # validates :address, length: { maximum: 200 }, allow_blank: true
  # validates :phone, length: { maximum: 20 }, allow_blank: true
  # validates :email, length: { maximum: 50 }, allow_blank: true
  # validates :contact_name, length: { maximum: 50 }, allow_blank: true
  # validates :contact_phone, length: { maximum: 20 }, allow_blank: true
  # validates :contact_title, length: { maximum: 50 }, allow_blank: true
  # validates :note, length: { maximum: 50 }, allow_blank: true
  # validates :comment, length: { maximum: 50 }, allow_blank: true

  # Relationships
  has_many :users, dependent: :destroy
  has_one :community_profile, dependent: :destroy

  # Scopes
  scope :enabled, -> { where(enable: true) }
  scope :sorted, -> { order(sort: :asc) }

  # Callbacks
  before_validation :ensure_token_presence

  private

  def ensure_token_presence
    self.token = SecureRandom.hex(10) if token.blank?
  end
end
