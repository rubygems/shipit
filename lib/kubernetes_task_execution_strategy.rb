# frozen_string_literal: true

require "json"
require "open3"

class KubernetesTaskExecutionStrategy < Shipit::TaskExecutionStrategy::Base
  class SubmissionError < StandardError; end

  SECRET_ENV = {
    "SECRET_KEY_BASE" => "secret_key_base",
    "DATABASE_URL" => "database_url",
    "REDIS_URL" => "redis_url",
    "SHIPIT_HOST" => "shipit_host",
    "SHIPIT_HOME_DIR" => "shipit_home_dir",
    "GITHUB_OAUTH_ID" => "github_oauth_id",
    "GITHUB_OAUTH_SECRET" => "github_oauth_secret",
    "GITHUB_APP_ID" => "github_app_id",
    "GITHUB_INSTALLATION_ID" => "github_installation_id",
    "GITHUB_WEBHOOK_SECRET" => "github_webhook_secret",
    "GITHUB_PRIVATE_KEY" => "github_private_key",
    "PREVIOUS_ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY" => "previous_active_record_encryption_primary_key",
    "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY" => "active_record_encryption_primary_key",
    "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY" => "active_record_encryption_deterministic_key",
    "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT" => "active_record_encryption_key_derivation_salt"
  }.freeze

  def execute
    _stdout, stderr, status = Open3.capture3(
      "kubectl", "create", "--namespace", namespace, "-f", "-",
      stdin_data: JSON.generate(job)
    )
    raise SubmissionError, "kubectl failed to create task Job: #{stderr.strip}" unless status.success?
  rescue => error
    task.report_error!(error)
  end

  private

  def namespace
    ENV.fetch("SHIPIT_TASK_NAMESPACE", "shipit")
  end

  def job
    revision = task.until_commit.sha
    labels = {
      "app.kubernetes.io/name" => "shipit-task",
      "shipit.rubygems.org/task-id" => task.id.to_s,
      "shipit.rubygems.org/revision" => revision
    }

    {
      "apiVersion" => "batch/v1",
      "kind" => "Job",
      "metadata" => {
        "name" => "shipit-task-#{task.id}",
        "labels" => labels
      },
      "spec" => {
        "activeDeadlineSeconds" => 3_600,
        "backoffLimit" => 0,
        "ttlSecondsAfterFinished" => 86_400,
        "template" => {
          "metadata" => {
            "annotations" => {
              "ad.datadoghq.com/task.logs" => JSON.generate([
                { "source" => "rails", "service" => "shipit", "version" => revision }
              ])
            },
            "labels" => labels.merge(
              "tags.datadoghq.com/env" => "production",
              "tags.datadoghq.com/service" => "shipit",
              "tags.datadoghq.com/version" => revision
            )
          },
          "spec" => {
            "serviceAccountName" => "shipit-task",
            "restartPolicy" => "Never",
            "containers" => [ container(revision) ],
            "volumes" => [
              {
                "name" => "ejson-keys",
                "secret" => { "secretName" => "ejson-keys" }
              }
            ]
          }
        }
      }
    }
  end

  def container(revision)
    {
      "name" => "task",
      "image" => ENV.fetch("SHIPIT_TASK_IMAGE"),
      "command" => [ "bin/rails" ],
      "args" => [ "shipit:task:run[#{task.id}]" ],
      "resources" => {
        "requests" => { "cpu" => "200m", "memory" => "1Gi" },
        "limits" => { "cpu" => "1000m", "memory" => "2Gi" }
      },
      "env" => environment(revision),
      "volumeMounts" => [
        {
          "name" => "ejson-keys",
          "mountPath" => "/opt/ejson/keys",
          "readOnly" => true
        }
      ],
      "securityContext" => { "privileged" => false }
    }
  end

  def environment(revision)
    [
      value("RAILS_ENV", "production"),
      value("ENV", "production"),
      value("KUBECONFIG", "/home/deploy/.kube/config"),
      value("RAILS_LOG_TO_STDOUT", "true"),
      value("SHIPIT_KUBERNETES_TASK_EXECUTOR", "false"),
      value("SHIPIT_TASK_EXECUTOR", "kubernetes"),
      value("DD_VERSION", revision),
      value("DD_TAGS", "service:shipit env:production version:#{revision}"),
      value("STATSD_IMPLEMENTATION", "datadog"),
      value("STATSD_ADDR", "$(DD_AGENT_HOST):8125"),
      field("DD_AGENT_HOST", "status.hostIP"),
      field("SHIPIT_TASK_POD_NAME", "metadata.name"),
      field("SHIPIT_TASK_JOB_NAME", "metadata.labels['batch.kubernetes.io/job-name']"),
      *SECRET_ENV.map { |name, key| secret(name, key) }
    ]
  end

  def value(name, content)
    { "name" => name, "value" => content }
  end

  def field(name, field_path)
    {
      "name" => name,
      "valueFrom" => {
        "fieldRef" => { "apiVersion" => "v1", "fieldPath" => field_path }
      }
    }
  end

  def secret(name, key)
    {
      "name" => name,
      "valueFrom" => {
        "secretKeyRef" => { "name" => "production", "key" => key }
      }
    }
  end
end
