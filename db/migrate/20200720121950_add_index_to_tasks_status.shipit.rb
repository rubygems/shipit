# This migration comes from shipit (originally 20200226211925)
class AddIndexToTasksStatus < ActiveRecord::Migration[6.0]
  def change
    add_index :tasks, :status
  end
end
