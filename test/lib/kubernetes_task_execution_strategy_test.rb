# frozen_string_literal: true

require "test_helper"
require "open3"
require "rake"
require "tmpdir"
require "yaml"

class KubernetesTaskExecutionStrategyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @original_setting = ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"]
    @original_strategy = Shipit.task_execution_strategy
  end

  teardown do
    ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"] = @original_setting
    Shipit.task_execution_strategy = @original_strategy
  end

  test "selects the Kubernetes strategy when enabled" do
    ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"] = "true"

    load Rails.root.join("config/initializers/task_execution_strategy.rb")

    assert_equal KubernetesTaskExecutionStrategy, Shipit.task_execution_strategy
  end

  test "boots with the Kubernetes strategy enabled" do
    stdout, stderr, status = Open3.capture3(
      { "RAILS_ENV" => "test", "SHIPIT_KUBERNETES_TASK_EXECUTOR" => "true" },
      Rails.root.join("bin/rails").to_s,
      "runner",
      "puts Shipit.task_execution_strategy.name"
    )

    assert status.success?, stderr
    assert_includes stdout, "KubernetesTaskExecutionStrategy"
  end

  test "preserves the default strategy when disabled" do
    Shipit.task_execution_strategy = nil
    ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"] = "false"

    load Rails.root.join("config/initializers/task_execution_strategy.rb")

    assert_equal Shipit::TaskExecutionStrategy::Default, Shipit.task_execution_strategy
  end

  test "submits a standalone Job containing the task execution contract" do
    task = shipit_tasks(:shipit)
    revision = task.until_commit.sha

    with_capturing_kubectl do |manifest, arguments|
      KubernetesTaskExecutionStrategy.new(task).execute

      assert_equal [ "create", "--namespace", "shipit", "-f", "-" ], arguments.call

      job = manifest.call
      assert_equal "batch/v1", job.fetch("apiVersion")
      assert_equal "Job", job.fetch("kind")
      assert_equal "shipit-task-#{task.id}", job.dig("metadata", "name")
      assert_equal task.id.to_s, job.dig("metadata", "labels", "shipit.rubygems.org/task-id")
      assert_equal revision, job.dig("metadata", "labels", "shipit.rubygems.org/revision")
      assert_equal 0, job.dig("spec", "backoffLimit")
      assert_equal 3_600, job.dig("spec", "activeDeadlineSeconds")
      assert_equal 86_400, job.dig("spec", "ttlSecondsAfterFinished")

      pod_spec = job.dig("spec", "template", "spec")
      assert_equal "shipit-task", pod_spec.fetch("serviceAccountName")
      assert_equal "Never", pod_spec.fetch("restartPolicy")

      container = pod_spec.fetch("containers").sole
      assert_equal "quay.io/rubygems/shipit:test-revision", container.fetch("image")
      assert_equal [ "bin/rails" ], container.fetch("command")
      assert_equal [ "shipit:task:run[#{task.id}]" ], container.fetch("args")

      env = container.fetch("env").index_by { |entry| entry.fetch("name") }
      %w[DATABASE_URL REDIS_URL GITHUB_PRIVATE_KEY SHIPIT_HOST SECRET_KEY_BASE].each do |name|
        assert_equal "production", env.dig(name, "valueFrom", "secretKeyRef", "name")
      end
      assert_equal "status.hostIP", env.dig("DD_AGENT_HOST", "valueFrom", "fieldRef", "fieldPath")
      assert_equal "metadata.name", env.dig("SHIPIT_TASK_POD_NAME", "valueFrom", "fieldRef", "fieldPath")

      # Kubernetes only expands $(VAR) references to variables defined earlier in the list.
      names = container.fetch("env").map { |entry| entry.fetch("name") }
      assert_equal "$(DD_AGENT_HOST):8125", env.dig("STATSD_ADDR", "value")
      assert_operator names.index("DD_AGENT_HOST"), :<, names.index("STATSD_ADDR")
    end
  end

  test "a redelivered submission leaves the task to its existing Job" do
    task = shipit_tasks(:shipit)
    task.update_columns(status: "running")
    already_exists = %(Error from server (AlreadyExists): error when creating "STDIN": ) +
      %(jobs.batch "shipit-task-#{task.id}" already exists)

    with_failing_kubectl(already_exists) do
      KubernetesTaskExecutionStrategy.new(task).execute
    end

    assert_equal "running", task.reload.status
  end

  test "a failed submission errors the task" do
    task = shipit_tasks(:shipit)
    task.update_columns(status: "pending")
    forbidden = %(Error from server (Forbidden): error when creating "STDIN": jobs.batch is forbidden)

    with_failing_kubectl(forbidden) do
      KubernetesTaskExecutionStrategy.new(task).execute
    end

    assert_equal "error", task.reload.status
  end

  test "the standalone runner schedules output rollup after execution finishes" do
    Rails.application.load_tasks unless Rake::Task.task_defined?("shipit:task:run")
    task = shipit_tasks(:shipit)
    task.update_columns(status: "success", rolled_up: false)

    rake_task = Rake::Task["shipit:task:run"]
    rake_task.reenable
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    assert_enqueued_with(job: Shipit::ChunkRollupJob, args: [ task ]) do
      rake_task.invoke(task.id)
    end
  ensure
    ActiveJob::Base.queue_adapter = original_adapter if original_adapter
  end

  private

  def with_failing_kubectl(stderr, &)
    with_capturing_kubectl(<<~SH, &)
      echo '#{stderr}' >&2
      exit 1
    SH
  end

  def with_capturing_kubectl(outcome = "")
    Dir.mktmpdir do |directory|
      manifest_path = File.join(directory, "manifest.yml")
      arguments_path = File.join(directory, "arguments")
      kubectl_path = File.join(directory, "kubectl")
      File.write(kubectl_path, <<~SH)
        #!/bin/sh
        cat > "$KUBECTL_CAPTURE"
        printf '%s\n' "$@" > "$KUBECTL_ARGUMENTS_CAPTURE"
        #{outcome}
      SH
      File.chmod(0o755, kubectl_path)

      environment = {
        "KUBECTL_CAPTURE" => manifest_path,
        "KUBECTL_ARGUMENTS_CAPTURE" => arguments_path,
        "PATH" => "#{directory}:#{ENV.fetch("PATH")}",
        "SHIPIT_TASK_IMAGE" => "quay.io/rubygems/shipit:test-revision",
        "SHIPIT_TASK_NAMESPACE" => "shipit"
      }
      original_environment = environment.keys.to_h { |name| [ name, ENV[name] ] }

      environment.each { |name, value| ENV[name] = value }
      yield -> { YAML.safe_load_file(manifest_path) }, -> { File.readlines(arguments_path, chomp: true) }
    ensure
      original_environment&.each { |name, value| ENV[name] = value }
    end
  end
end
