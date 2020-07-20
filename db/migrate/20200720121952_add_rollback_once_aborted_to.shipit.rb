# This migration comes from shipit (originally 20200615181558)
class AddRollbackOnceAbortedTo < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :rollback_once_aborted_to_id, :integer
  end
end
