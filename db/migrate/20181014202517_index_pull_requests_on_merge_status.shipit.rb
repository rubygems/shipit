# This migration comes from shipit (originally 20170524084548)
class IndexPullRequestsOnMergeStatus < ActiveRecord::Migration[5.1]
  def change
    add_index :pull_requests, :merge_status
  end
end
