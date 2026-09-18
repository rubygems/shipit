# frozen_string_literal: true

namespace :shipit do
  namespace :task do
    desc "Run a Shipit task with the in-process execution strategy"
    task :run, [ :task_id ] => :environment do |_task, arguments|
      task = Shipit::Task.find(arguments.fetch(:task_id))
      Shipit::TaskExecutionStrategy::Default.new(task).execute

      # The state-machine callback may enqueue its rollup before the successful
      # transition is visible to Sidekiq. Enqueue again from outside that
      # transition so standalone task Jobs reliably persist their output.
      task.reload.schedule_rollup_chunks if task.finished? && !task.rolled_up?
    end
  end
end
