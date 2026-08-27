# frozen_string_literal: true

module DatadogDeployHook
  module_function

  EVENTS = %i[deploy rollback].freeze
  LIFECYCLE = {
    "running" => [ "started", "info" ],
    "success" => [ "succeeded", "success" ],
    "failed" => [ "failed", "error" ],
    "error" => [ "failed", "error" ],
    "timedout" => [ "failed", "error" ],
    "faulty" => [ "failed", "error" ],
    "aborted" => [ "was interrupted", "warning" ]
  }.freeze

  def deliver(event, stack, payload)
    return unless EVENTS.include?(event.to_sym)

    outcome, alert_type = LIFECYCLE[payload[:status]]
    return unless outcome

    deploy = payload[event.to_sym]
    return unless deploy

    deployer = deploy.user&.login || "unknown"
    service = stack.repo_name
    environment = stack.environment
    revision = deploy.until_commit.sha
    action, preposition = event.to_sym == :rollback ? [ "rolling back", "in" ] : [ "deploying", "to" ]

    commit_lines = deploy.commits.map { |c| "* #{c.short_sha} #{c.title}" }

    title = "#{deployer} #{outcome} #{action} #{service} #{preposition} #{environment}"
    text = [ title, "", *commit_lines ].join("\n")
    tags = [
      "service:#{service}",
      "env:#{environment}",
      "version:#{revision}",
      "revision:#{revision}",
      "task_id:#{deploy.id}",
      "executor:#{ENV.fetch("SHIPIT_TASK_EXECUTOR", "sidekiq")}",
      "source:shipit-deploy"
    ]
    tags << "pod_name:#{ENV["SHIPIT_TASK_POD_NAME"]}" if ENV["SHIPIT_TASK_POD_NAME"].present?
    tags << "job_name:#{ENV["SHIPIT_TASK_JOB_NAME"]}" if ENV["SHIPIT_TASK_JOB_NAME"].present?

    send_event(title, text, tags:, alert_type:)
  end

  def send_event(title, text, tags:, alert_type:)
    host = ENV.fetch("DD_AGENT_HOST", "localhost")

    Datadog::Statsd.open(host, 8125) do |statsd|
      statsd.event(title, text, {
        tags:,
        alert_type:,
        source_type_name: "shipit"
      })
    end
  rescue => e
    Rails.logger.error("[DatadogDeployHook] Failed to send event: #{e.message}")
  end
end
