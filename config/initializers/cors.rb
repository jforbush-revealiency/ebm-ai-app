Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed = [
      'http://localhost:3001',
      'http://localhost:3000',
      'https://reportgarden-pro.lovable.app',
      'https://*.lovable.app',
      'https://*.lovableproject.com',
      ENV['FRONTEND_URL']
    ].compact
    origins(*allowed)
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true,
      max_age: 86400
  end
end