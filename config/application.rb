require_relative 'boot'

require 'csv'
require 'rails/all'

Bundler.require(*Rails.groups)

module Ebmpro
  class Application < Rails::Application
    config.load_defaults 7.1

    # ── API Mode ──────────────────────────────────────────────
    # The frontend (Lovable/React) is a separate app.
    # Rails serves JSON only — no HTML views for the API routes.
    config.api_only = false  # Keep false to serve the login page;
                              # flip to true once frontend is fully on Lovable

    # ── Time zones ────────────────────────────────────────────
    config.time_zone = 'Mountain Time (US & Canada)'
    config.active_record.default_timezone = :utc
    config.active_record.time_zone_aware_types = [:datetime]

    # ── CORS ──────────────────────────────────────────────────
    # Configured in config/initializers/cors.rb
  end
end
