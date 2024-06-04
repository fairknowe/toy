# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Toy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    config.log_formatter = ActiveSupport::Logger::Formatter.new
    config.log_formatter = proc do |severity, datetime, _progname, msg|
      "#{datetime}: #{severity} : #{msg}\n"
    end

    config.assets.prefix = "/api/assets"

    if ShopifyAPI::Context.embedded?
      config.action_dispatch.default_headers = config.action_dispatch.default_headers.merge({
        # "Access-Control-Allow-Origin" => "*", # Uncomment this line to allow all origins
        "Access-Control-Allow-Origin" => "http://localhost:3001",
        "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept, Authorization, X-Requested-With",
        "Access-Control-Expose-Headers" => "X-Shopify-API-Request-Failure-Reauthorize-Url",
        "Access-Control-Allow-Credentials" => "true",
      })
    end

    config.active_record.schema_format = :ruby
    config.time_zone = "Eastern Time (US & Canada)"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
