class AddThemeFieldsToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :communities, :host, :string, limit: 255, comment: "社群主網域"
    add_column :communities, :theme_key, :string, limit: 50, null: false, default: "valex", comment: "主題鍵值"
    add_column :communities, :layout_preset, :string, limit: 50, null: false, default: "valex", comment: "版型預設"
    add_column :communities, :theme_settings, :json, comment: "主題設定(JSON)"

    add_index :communities, :host, unique: true
    add_index :communities, :theme_key
  end
end
