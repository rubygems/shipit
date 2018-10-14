# This migration comes from shipit (originally 20170629141736)
class AddIgnoredSafetiesOnTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :ignored_safeties, :boolean, default: false, null: false
  end
end
