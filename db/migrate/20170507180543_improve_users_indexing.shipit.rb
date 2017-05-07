# This migration comes from shipit (originally 20170220152410)
class ImproveUsersIndexing < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :updated_at
    add_index :users, :github_id
  end
end
