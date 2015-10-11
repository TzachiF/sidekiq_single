require 'sidekiq'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
require 'sidekiq_single/extensions/basic_fetch'
    chain.add SidekiqSingle::Middleware::Server
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqSingle::Middleware::Client
  end
end
