# frozen_string_literal: true

Rails.application.config.after_initialize do
  if ActiveModel::Type::Boolean.new.cast(ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"])
    require Rails.root.join("lib/kubernetes_task_execution_strategy").to_s
    Shipit.task_execution_strategy = KubernetesTaskExecutionStrategy
  end
end
