# This migration comes from shipit (originally 20230703181143)
class ChangeCommitDeploymentStatusesGithubIdToBigInt < ActiveRecord::Migration[7.0]
  def change
    change_column :commit_deployment_statuses, :github_id, :bigint
  end
end
