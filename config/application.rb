require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SwitchRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Pacific Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.active_storage.service = :local
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.track_variants = true
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    Koala.config.api_version = "v2.0"
  end
end
