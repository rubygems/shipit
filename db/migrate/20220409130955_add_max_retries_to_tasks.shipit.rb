# This migration comes from shipit (originally 20201008152744)
class AddMaxRetriesToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :max_retries, :integer, null: true
  end
end
