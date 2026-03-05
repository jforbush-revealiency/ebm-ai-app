source 'https://rubygems.org'

ruby '3.2.2'

# ── Core ────────────────────────────────────────────────────
gem 'rails', '~> 7.1.0'
gem 'pg', '~> 1.5'          # PostgreSQL (replaces mysql2)
gem 'puma', '~> 6.0'

# ── API / Serialization ─────────────────────────────────────
gem 'rack-cors'              # Allow Lovable frontend to call API
gem 'jbuilder', '~> 2.11'

# ── Authentication ───────────────────────────────────────────
gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.11' # JWT tokens for API auth (replaces cookie sessions)
gem 'cancancan', '~> 3.5'

# ── AWS / Storage ────────────────────────────────────────────
gem 'aws-sdk-s3', '~> 1.0'  # Replaces old aws-sdk (v1)

# ── Background Jobs ──────────────────────────────────────────
gem 'sidekiq', '~> 7.0'     # Redis-backed job queue (replaces default ActiveJob)

# ── Utilities ────────────────────────────────────────────────
gem 'dotenv-rails'           # Load .env file in development
gem 'bootsnap', require: false

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'    # Replaces factory_girl_rails (renamed)
  gem 'rspec-rails', '~> 6.0'
end

group :development do
  gem 'listen', '~> 3.8'
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
end
