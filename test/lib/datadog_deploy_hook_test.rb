# frozen_string_literal: true

require "test_helper"

class DatadogDeployHookTest < ActiveSupport::TestCase
  setup do
    @stack = shipit_stacks(:shipit)
    @deploy = shipit_tasks(:shipit)
    @sent_events = []
    sent_events = @sent_events

    # Stub send_event to capture calls instead of hitting Datadog
    DatadogDeployHook.singleton_class.alias_method(:original_send_event, :send_event)
    DatadogDeployHook.define_singleton_method(:send_event) do |title, text, service:, environment:|
      sent_events << { title:, text:, service:, environment: }
    end
  end

  teardown do
    DatadogDeployHook.singleton_class.alias_method(:send_event, :original_send_event)
    DatadogDeployHook.singleton_class.remove_method(:original_send_event) if DatadogDeployHook.respond_to?(:original_send_event)
  end

  test "sends datadog event when deploy is running" do
    payload = { deploy: @deploy, status: "running", stack: @stack }
    DatadogDeployHook.deliver(:deploy, @stack, payload)

    assert_equal 1, @sent_events.size
    event = @sent_events.first
    assert_equal "walrus is deploying to #{@stack.repo_name} #{@stack.environment}", event[:title]
    assert_includes event[:text], "walrus is deploying to #{@stack.repo_name} #{@stack.environment}"
    assert_equal @stack.repo_name, event[:service]
    assert_equal @stack.environment, event[:environment]
  end

  test "sends datadog event when rollback is running" do
    rollback = shipit_tasks(:shipit_rollback)
    payload = { rollback: rollback, status: "running", stack: @stack }
    DatadogDeployHook.deliver(:rollback, @stack, payload)

    assert_equal 1, @sent_events.size
    event = @sent_events.first
    assert_equal "bob is rolling back #{@stack.repo_name} #{@stack.environment}", event[:title]
    assert_includes event[:text], "bob is rolling back #{@stack.repo_name} #{@stack.environment}"
  end

  test "includes commit details in event text" do
    payload = { deploy: @deploy, status: "running", stack: @stack }
    DatadogDeployHook.deliver(:deploy, @stack, payload)

    event = @sent_events.first
    @deploy.commits.each do |commit|
      assert_includes event[:text], "* #{commit.short_sha} #{commit.title}"
    end
  end

  test "ignores non-deploy events" do
    payload = { deploy: @deploy, status: "running", stack: @stack }
    DatadogDeployHook.deliver(:lock, @stack, payload)

    assert_empty @sent_events
  end

  test "ignores non-running statuses" do
    payload = { deploy: @deploy, status: "success", stack: @stack }
    DatadogDeployHook.deliver(:deploy, @stack, payload)

    assert_empty @sent_events
  end
end
