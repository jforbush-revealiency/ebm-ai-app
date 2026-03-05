Rails.application.configure do
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.log_level = :info
  config.log_tags = [:request_id]

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false

  # ── Email (AWS SES or any SMTP provider) ──────────────────────────────────
  # Set SMTP_* environment variables in Render dashboard.
  # For AWS SES: SMTP_HOST = email-smtp.us-west-2.amazonaws.com
  # Create SMTP credentials in AWS Console → SES → SMTP Settings
  # (These are different from your IAM access keys)
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch('SMTP_HOST', 'email-smtp.us-west-2.amazonaws.com'),
    port:                 ENV.fetch('SMTP_PORT', 587).to_i,
    domain:               ENV.fetch('SMTP_DOMAIN', 'ebmpros.com'),
    user_name:            ENV['SMTP_USERNAME'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = {
    host: ENV.fetch('APP_HOST', 'app.ebmpros.com')
  }

  # ── Logging ───────────────────────────────────────────────────────────────
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.after_initialize do
    Rails.logger.info "EBM AI production server started."
  end
end
