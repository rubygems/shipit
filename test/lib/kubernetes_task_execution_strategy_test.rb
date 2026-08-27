# frozen_string_literal: true

require "test_helper"
require "open3"
require "tmpdir"
require "yaml"

class KubernetesTaskExecutionStrategyTest < ActiveSupport::TestCase
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
    end
  end

  private

  def with_capturing_kubectl
    Dir.mktmpdir do |directory|
      manifest_path = File.join(directory, "manifest.yml")
      arguments_path = File.join(directory, "arguments")
      kubectl_path = File.join(directory, "kubectl")
      File.write(kubectl_path, <<~SH)
        #!/bin/sh
        cat > "$KUBECTL_CAPTURE"
        printf '%s\n' "$@" > "$KUBECTL_ARGUMENTS_CAPTURE"
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
