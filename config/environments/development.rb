Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  # ── Email ──────────────────────────────────────────────────────────────────
  # In development, emails are caught by Letter Opener (opens in browser tab)
  # instead of actually sending. Add 'letter_opener' to Gemfile to enable.
  # To use real SMTP in dev, set SMTP_* vars in your .env file.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  if ENV['SMTP_HOST'].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['SMTP_HOST'],
      port:                 ENV.fetch('SMTP_PORT', 587).to_i,
      domain:               ENV.fetch('SMTP_DOMAIN', 'localhost'),
      user_name:            ENV['SMTP_USERNAME'],
      password:             ENV['SMTP_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
    }
  else
    config.action_mailer.delivery_method = :letter_opener rescue :test
  end

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.assets.debug = true
  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.after_initialize do
    Rails.logger.info "EBM AI development server started."
  end
end
