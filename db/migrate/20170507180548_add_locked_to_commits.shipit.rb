# This migration comes from shipit (originally 20170320124156)
class AddLockedToCommits < ActiveRecord::Migration[5.0]
  def change
    add_column :commits, :locked, :boolean, default: false, null: false
  end
end
