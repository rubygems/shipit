require "fileutils"

SIDEKIQ_READY_FILE = Rails.root.join("tmp/sidekiq-ready").freeze

Sidekiq.configure_server do |config|
  config.redis = { url: Shipit.redis_url.to_s }

  config.on(:startup) do
    FileUtils.touch(SIDEKIQ_READY_FILE)
  end

  config.on(:shutdown) do
    FileUtils.rm_f(SIDEKIQ_READY_FILE)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Shipit.redis_url.to_s }
end
