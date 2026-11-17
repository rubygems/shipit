# frozen_string_literal: true

require "test_helper"

class ReapUnstartedTasksJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @original_strategy = Shipit.task_execution_strategy
    Shipit.task_execution_strategy = KubernetesTaskExecutionStrategy
    @task = shipit_tasks(:shipit_pending)
    # Shipit Engine's other pending fixtures have no task definition and cannot change state.
    Shipit::Task.where(status: "pending").where.not(id: @task.id).delete_all
  end

  teardown do
    Shipit.task_execution_strategy = @original_strategy
  end

  test "errors a task that its Job did not start in time" do
    @task.update_columns(created_at: 11.minutes.ago)
    running = shipit_tasks(:shipit_running)

    ReapUnstartedTasksJob.perform_now

    assert_equal "error", @task.reload.status
    assert_includes @task.chunk_output, "shipit-task-#{@task.id} did not start"
    assert_equal "running", running.reload.status
  end

  test "leaves a recently submitted task pending" do
    @task.update_columns(created_at: 9.minutes.ago)

    ReapUnstartedTasksJob.perform_now

    assert_equal "pending", @task.reload.status
  end

  test "leaves tasks queued for the default strategy pending" do
    Shipit.task_execution_strategy = nil
    @task.update_columns(created_at: 11.minutes.ago)

    ReapUnstartedTasksJob.perform_now

    assert_equal "pending", @task.reload.status
  end

  private

  def queue_adapter_for_test
    ActiveJob::QueueAdapters::TestAdapter.new
  end
end
