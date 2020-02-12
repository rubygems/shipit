# This migration comes from shipit (originally 20200109132519)
class AddShaToCommitDeployments < ActiveRecord::Migration[6.0]
  def change
    add_column :commit_deployments, :sha, :string, limit: 40
  end
end
