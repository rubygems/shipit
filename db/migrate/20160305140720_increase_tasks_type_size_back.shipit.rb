# This migration comes from shipit (originally 20160104151742)
class IncreaseTasksTypeSizeBack < ActiveRecord::Migration[4.2]
  def change
    change_column :tasks, :type, :string, limit: 20, null: true
  end
end
