# frozen_string_literal: true

require "test_helper"

class DatadogDeployHookTest < ActiveSupport::TestCase
  setup do
    @stack = shipit_stacks(:shipit)
    @deploy = shipit_tasks(:shipit)
    @sent_events = []
    @original_executor = ENV["SHIPIT_TASK_EXECUTOR"]
    @original_pod_name = ENV["SHIPIT_TASK_POD_NAME"]
    @original_job_name = ENV["SHIPIT_TASK_JOB_NAME"]
    ENV["SHIPIT_TASK_EXECUTOR"] = "kubernetes"
    ENV["SHIPIT_TASK_POD_NAME"] = "shipit-task-123-abcde"
    ENV["SHIPIT_TASK_JOB_NAME"] = "shipit-task-123"
    sent_events = @sent_events

    # Stub send_event to capture calls instead of hitting Datadog
    DatadogDeployHook.singleton_class.alias_method(:original_send_event, :send_event)
    DatadogDeployHook.define_singleton_method(:send_event) do |title, text, tags:, alert_type:|
      sent_events << { title:, text:, tags:, alert_type: }
    end
  end

  teardown do
    ENV["SHIPIT_TASK_EXECUTOR"] = @original_executor
    ENV["SHIPIT_TASK_POD_NAME"] = @original_pod_name
    ENV["SHIPIT_TASK_JOB_NAME"] = @original_job_name
    DatadogDeployHook.singleton_class.alias_method(:send_event, :original_send_event)
    DatadogDeployHook.singleton_class.remove_method(:original_send_event) if DatadogDeployHook.respond_to?(:original_send_event)
  end

  test "emits a started deployment event" do
    payload = { deploy: @deploy, status: "running", stack: @stack }
    DatadogDeployHook.deliver(:deploy, @stack, payload)

    event = @sent_events.first
    assert_equal "walrus started deploying #{@stack.repo_name} to #{@stack.environment}", event[:title]
    assert_equal "info", event[:alert_type]
    assert_includes event[:text], event[:title]
  end

  test "emits a started rollback event" do
    rollback = shipit_tasks(:shipit_rollback)
    DatadogDeployHook.deliver(:rollback, @stack, rollback:, status: "running")

    event = @sent_events.first
    assert_equal "bob started rolling back #{@stack.repo_name} in #{@stack.environment}", event[:title]
  end

  test "emits succeeded, failed, and interrupted terminal events" do
    {
      "success" => [ "succeeded", "success" ],
      "failed" => [ "failed", "error" ],
      "error" => [ "failed", "error" ],
      "timedout" => [ "failed", "error" ],
      "faulty" => [ "failed", "error" ],
      "aborted" => [ "was interrupted", "warning" ]
    }.each do |status, (result, alert_type)|
      @sent_events.clear
      DatadogDeployHook.deliver(:deploy, @stack, deploy: @deploy, status:)

      event = @sent_events.first
      assert_includes event[:title], result
      assert_equal alert_type, event[:alert_type]
    end
  end

  test "includes commits and unified deployment tags" do
    DatadogDeployHook.deliver(:deploy, @stack, deploy: @deploy, status: "running")

    event = @sent_events.first
    @deploy.commits.each do |commit|
      assert_includes event[:text], "* #{commit.short_sha} #{commit.title}"
    end

    assert_includes event[:tags], "service:#{@stack.repo_name}"
    assert_includes event[:tags], "env:#{@stack.environment}"
    assert_includes event[:tags], "version:#{@deploy.until_commit.sha}"
    assert_includes event[:tags], "revision:#{@deploy.until_commit.sha}"
    assert_includes event[:tags], "task_id:#{@deploy.id}"
    assert_includes event[:tags], "executor:kubernetes"
    assert_includes event[:tags], "pod_name:shipit-task-123-abcde"
    assert_includes event[:tags], "job_name:shipit-task-123"
  end

  test "ignores unrelated events and statuses" do
    DatadogDeployHook.deliver(:lock, @stack, deploy: @deploy, status: "running")
    %w[pending validating flapping aborting].each do |status|
      DatadogDeployHook.deliver(:deploy, @stack, deploy: @deploy, status:)
    end

    assert_empty @sent_events
  end
end
