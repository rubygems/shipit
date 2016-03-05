# This migration comes from shipit (originally 20160210183823)
class AddAllowConcurrencyToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :allow_concurrency, :boolean, null: false, default: false
  end
end
