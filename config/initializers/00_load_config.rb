## APP_CONFIG = YAML.load_file("#{::Rails.root.to_s}/config/settings.yml")[::Rails.env].symbolize_keys

file_path = File.expand_path("#{::Rails.root.to_s}/config/settings.yml", __FILE__)
yaml_contents = File.read(file_path)
loaded_config = YAML.load(yaml_contents, aliases: true) || {}

# test / preview 環境若未明確配置，退回 development 以避免 boot 失敗
current_env_config = loaded_config[::Rails.env] || loaded_config["development"] || loaded_config["default"] || {}
APP_CONFIG = current_env_config.symbolize_keys