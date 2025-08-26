class ChangeGithubIdToBigintInCommitDeployments < ActiveRecord::Migration[7.1]
  def up
    change_column :commit_deployments, :github_id, :bigint
  end

  def down
    change_column :commit_deployments, :github_id, :integer
  end
end
