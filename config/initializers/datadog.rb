# frozen_string_literal: true

Datadog.configure do |c|
  # unified service tagging
  c.service = "shipit"
  c.env = Rails.env

  # Enabling datadog functionality
  running_locally = Rails.env.local? || defined?(Rails::Console)
  enabled = !running_locally || ENV["DD_AGENT_HOST"].present?
  c.runtime_metrics.enabled = enabled
  c.tracing.enabled = enabled
  c.tracing.log_injection = enabled
  c.telemetry.enabled = enabled
  c.remote.enabled = enabled

  unless enabled
    c.tracing.log_injection = false
    c.tracing.test_mode.enabled = true
    c.diagnostics.startup_logs.enabled = false
  end

  if enabled
    c.tracing.report_hostname = true

    c.tracing.instrument :faraday, split_by_domain: true, service_name: c.service
    c.tracing.instrument :mysql2
    c.tracing.instrument :rails
    c.tracing.instrument :sidekiq
  end
end

require "datadog/auto_instrument"
