# frozen_string_literal: true

# Enqueued every minute by the minutely CronJob and performed by Sidekiq, which knows the
# configured strategy. The default in-Sidekiq strategy defines no reaper, so the tasks it
# has queued stay pending for as long as they need.
class ReapUnstartedTasksJob < Shipit::BackgroundJob
  queue_as :default

  def perform
    strategy = Shipit.task_execution_strategy
    strategy.reap_unstarted_tasks if strategy.respond_to?(:reap_unstarted_tasks)
  end
end
