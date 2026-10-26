require "test_helper"

class StackPagesTest < ActionDispatch::IntegrationTest
  setup do
    @previous_disable_auth = ENV["SHIPIT_DISABLE_AUTH"]
    ENV["SHIPIT_DISABLE_AUTH"] = "1"
    @stack = shipit_stacks(:shipit)
  end

  teardown do
    ENV["SHIPIT_DISABLE_AUTH"] = @previous_disable_auth
  end

  test "previous deploys use model-specific links and details" do
    cases = [
      [ shipit_tasks(:shipit2), "deploys", /deployed/ ],
      [ shipit_tasks(:shipit_rollback), "deploys", /rolled back to/ ],
      [ shipit_tasks(:shipit_restart), "tasks", /executed restart/ ]
    ]
    cases.each do |task, _, _|
      task.update_columns(rolled_up: true, gzip_output: ActiveSupport::Gzip.compress("Task output\n"))
    end

    get "/#{@stack.to_param}"

    assert_response :success
    links = cases.map do |task, resource, title|
      path = "/#{@stack.to_param}/#{resource}/#{task.id}"
      assert_select "#task-#{task.id} .status[href=?]", path
      assert_select "#task-#{task.id} .commit-title a[href=?]", path
      [ path, title ]
    end
    assert_select "#task-#{shipit_tasks(:shipit2).id}.deploy .code-additions", text: "+12"
    assert_select "#task-#{shipit_tasks(:shipit2).id}.deploy .code-deletions", text: "-64"
    assert_select "#task-#{shipit_tasks(:shipit_rollback).id} .commit-meta", text: /rolled back/
    assert_select "#task-#{shipit_tasks(:shipit_restart).id} .commit-meta", text: /ran a command/

    links.each do |path, title|
      get path

      assert_response :success
      assert_select ".deploy-status", text: title
    end
  end
end
