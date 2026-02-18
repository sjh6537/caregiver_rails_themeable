class Community < ApplicationRecord
  DEFAULT_THEME_SETTINGS = {
    "primary" => "#4f46e5",
    "secondary" => "#7c3aed",
    "accent" => "#f59e0b",
    "background" => "#f8fafc",
    "surface" => "#ffffff",
    "text" => "#0f172a",
    "muted_text" => "#475569"
  }.freeze

  # Relationships
  has_many :users, dependent: :destroy
  has_many :admins, dependent: :nullify
  has_one :community_profile, dependent: :destroy
  has_one_attached :theme_logo
  has_one_attached :theme_cover_image
  has_one_attached :theme_background_image

  # Scopes
  scope :enabled, -> { where(enable: true) }
  scope :sorted, -> { order(sort: :asc) }

  # Callbacks
  before_validation :ensure_sn_presence
  before_validation :normalize_theme_fields
  # 建立社區時，會自動建立一筆空的社區資料
  after_create :ensure_community_profile

  validates :theme_key, :layout_preset, presence: true
  validates :host, uniqueness: true, allow_blank: true

  def safe_theme_key
    sanitize_path_segment(theme_key, fallback: "valex")
  end

  def safe_layout_preset
    sanitize_path_segment(layout_preset, fallback: "valex")
  end

  # 供後台下拉選單顯示：名稱 (sn)，方便辨識並用 ?sn= 到前台預覽
  def name_with_sn
    sn.present? ? "#{name} (#{sn})" : name.to_s
  end

  def theme_settings_hash
    settings = theme_settings.is_a?(Hash) ? theme_settings.stringify_keys : {}
    DEFAULT_THEME_SETTINGS.merge(settings.slice(*DEFAULT_THEME_SETTINGS.keys))
  end

  def css_variables
    settings = theme_settings_hash

    {
      "--community-color-primary" => settings["primary"],
      "--community-color-secondary" => settings["secondary"],
      "--community-color-accent" => settings["accent"],
      "--community-color-background" => settings["background"],
      "--community-color-surface" => settings["surface"],
      "--community-color-text" => settings["text"],
      "--community-color-muted-text" => settings["muted_text"]
    }
  end

  private

  def ensure_sn_presence
    self.sn = SecureRandom.hex(10) if sn.blank?
  end

  def normalize_theme_fields
    self.host = host.to_s.strip.downcase.presence
    self.theme_key = sanitize_path_segment(theme_key, fallback: "valex")
    self.layout_preset = sanitize_path_segment(layout_preset, fallback: "valex")
    self.theme_settings = theme_settings_hash
  end

  def sanitize_path_segment(value, fallback:)
    cleaned = value.to_s.downcase.gsub(/[^a-z0-9_-]/, "")
    cleaned.presence || fallback
  end

  def ensure_community_profile
    create_community_profile if community_profile.nil?
  end
end
