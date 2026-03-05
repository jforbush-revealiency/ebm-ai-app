# CORS Configuration
# Allows the Lovable (React) frontend to call this Rails API.
# Set FRONTEND_URL in your .env file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('FRONTEND_URL', 'http://localhost:3001')

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],   # Required for JWT token passback
      credentials: true,
      max_age: 86400
  end
end
