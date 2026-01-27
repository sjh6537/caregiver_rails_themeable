require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LearningLife
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths << Rails.root.join('app/worker')

    config.i18n.default_locale = :'zh-TW'
    config.time_zone = 'Asia/Taipei'
    config.active_record.default_timezone = :utc
    config.active_job.queue_adapter = :sidekiq
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.after_initialize do
      Sidekiq::Scheduler.dynamic = true
    end

    config.hosts << 'padifield.line.miaoligo.com'
    config.hosts << 'padifield.admin.miaoligo.com'
    config.hosts << 'padifield.linebot.miaoligo.com'
    config.hosts << 'padifield.miaoligo.com'
    config.hosts << 'tianfu.miaoligo.com'
  end
end
