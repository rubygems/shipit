# frozen_string_literal: true

if ActiveModel::Type::Boolean.new.cast(ENV["SHIPIT_KUBERNETES_TASK_EXECUTOR"])
  Shipit.task_execution_strategy = KubernetesTaskExecutionStrategy
end
