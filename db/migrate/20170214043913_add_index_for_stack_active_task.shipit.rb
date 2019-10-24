# This migration comes from shipit (originally 20160426155146)
class AddIndexForStackActiveTask < ActiveRecord::Migration[4.2]
  def change
    add_index :tasks, [:status, :stack_id, :allow_concurrency], name: :index_active_tasks
  end
end
