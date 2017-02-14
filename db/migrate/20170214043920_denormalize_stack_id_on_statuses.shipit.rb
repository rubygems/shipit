# This migration comes from shipit (originally 20161206104224)
class DenormalizeStackIdOnStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :stack_id, :integer, null: true
  end
end
