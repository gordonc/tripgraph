Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://localhost', :namespace => 'sidekiq' }
  config.default_worker_options = { 'retry' => false }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://localhost', :namespace => 'sidekiq' }
  config.default_worker_options = { 'retry' => false }
end
