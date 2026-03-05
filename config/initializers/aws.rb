# AWS Configuration
# Credentials come from environment variables — the aws.json file has been removed.
# Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your .env file.

Aws.config.update({
  region: ENV.fetch('AWS_REGION', 'us-west-2'),
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  )
})
