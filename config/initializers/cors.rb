Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      'http://localhost:3001',
      'http://localhost:3000',
      'https://reportgarden-pro.lovable.app',
      ENV['FRONTEND_URL']
    ).compact

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true,
      max_age: 86400
  end
end