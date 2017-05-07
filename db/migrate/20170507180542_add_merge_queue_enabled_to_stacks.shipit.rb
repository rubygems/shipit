# This migration comes from shipit (originally 20170215123538)
class AddMergeQueueEnabledToStacks < ActiveRecord::Migration[5.0]
  def change
    add_column :stacks, :merge_queue_enabled, :boolean, default: false, null: false
  end
end
