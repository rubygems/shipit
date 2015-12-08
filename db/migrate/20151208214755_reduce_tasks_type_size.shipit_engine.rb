# This migration comes from shipit_engine (originally 20151112152112)
class ReduceTasksTypeSize < ActiveRecord::Migration
  def change
    change_column :tasks, :type, :string, limit: 10, null: true
  end
end
