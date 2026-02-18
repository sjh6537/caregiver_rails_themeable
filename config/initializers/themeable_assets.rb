theme_asset_roots = [
  Rails.root.join("app/themes"),
  Rails.root.join("vendor/javascript")
]

theme_asset_roots.each do |asset_root|
  next unless Dir.exist?(asset_root)

  Rails.application.config.assets.paths << asset_root
end
