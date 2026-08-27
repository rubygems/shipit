# frozen_string_literal: true

namespace :shipit do
  namespace :task do
    desc "Run a Shipit task with the in-process execution strategy"
    task :run, [ :task_id ] => :environment do |_task, arguments|
      task = Shipit::Task.find(arguments.fetch(:task_id))
      Shipit::TaskExecutionStrategy::Default.new(task).execute
    end
  end
end
