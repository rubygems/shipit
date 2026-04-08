# frozen_string_literal: true

module DatadogDeployHook
  module_function

  EVENTS = %i[deploy rollback].freeze

  def deliver(event, stack, payload)
    return unless EVENTS.include?(event.to_sym)
    return unless payload[:status] == "running"

    deploy = payload[event.to_sym]
    return unless deploy

    deployer = deploy.user&.login || "unknown"
    service = stack.repo_name
    environment = stack.environment
    action = event.to_sym == :rollback ? "rolling back" : "deploying to"

    commit_lines = deploy.commits.map { |c| "* #{c.short_sha} #{c.title}" }

    title = "#{deployer} is #{action} #{service} #{environment}"
    text = [ title, "", *commit_lines ].join("\n")

    send_event(title, text, service:, environment:)
  end

  def send_event(title, text, service:, environment:)
    host = ENV.fetch("DD_AGENT_HOST", "localhost")

    Datadog::Statsd.open(host, 8125) do |statsd|
      statsd.event(title, text, {
        tags: [ "service:#{service}", "environment:#{environment}" ],
        alert_type: "info",
        source_type_name: "shipit"
      })
    end
  rescue => e
    Rails.logger.error("[DatadogDeployHook] Failed to send event: #{e.message}")
  end
end
