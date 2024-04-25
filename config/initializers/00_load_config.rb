## APP_CONFIG = YAML.load_file("#{::Rails.root.to_s}/config/settings.yml")[::Rails.env].symbolize_keys

file_path = File.expand_path("#{::Rails.root.to_s}/config/settings.yml", __FILE__)
yaml_contents = File.read(file_path)
APP_CONFIG = YAML.load(yaml_contents, aliases: true)[::Rails.env].symbolize_keys