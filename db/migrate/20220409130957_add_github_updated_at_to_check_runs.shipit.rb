# This migration comes from shipit (originally 20210504200438)
class AddGithubUpdatedAtToCheckRuns < ActiveRecord::Migration[6.1]
  def change
    add_column :check_runs, :github_updated_at, :datetime, default: nil
  end
end
