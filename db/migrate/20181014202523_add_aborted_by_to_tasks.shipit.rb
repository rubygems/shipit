# This migration comes from shipit (originally 20180202220850)
class AddAbortedByToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :aborted_by_id, :integer
  end
end
