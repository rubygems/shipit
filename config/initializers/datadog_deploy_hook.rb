# frozen_string_literal: true

Rails.application.config.after_initialize do
  running_locally = Rails.env.local? || defined?(Rails::Console)
  enabled = !running_locally || ENV["DD_AGENT_HOST"].present?

  if enabled
    Shipit.internal_hook_receivers << DatadogDeployHook
  end
end
