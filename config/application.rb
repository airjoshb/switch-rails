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

     # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))
    #
    config.time_zone = "Pacific Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    config.add_autoload_paths_to_load_path = false

    # config.active_storage.service = :local
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.track_variants = true
    config.active_job.queue_adapter = :sidekiq
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    Koala.config.api_version = "v2.0"
  end
end
